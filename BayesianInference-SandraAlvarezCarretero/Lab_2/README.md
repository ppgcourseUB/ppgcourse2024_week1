# Lab 2: Phylogenetic Inference in `RevBayes`

We are going to program a Bayesian inference phylogenetic analysis in `RevBayes` using the `Rev` language. The three main components of a phylogenetic model (that we've learned about so far) are the *tree topology*, the *branch lengths*, and the *substitution model*. We will program them in this order.

## Data description and access

We are going to reconstruct the phylogeny of genus *Bufo* using a molecular dataset with two loci. Move into the `Lab_2` folder, where you can find all scripts and files needed for the practice. Inside this folder, create a second folder and name it `data`. Copy the *cytB.nex* and *16S.nex* files containing the sequences for these two mitochondrial markers from the pggcourse website into the `Lab_2/data` folder.

```sh
# Run from `Lab_2`
mkdir data
cp -p cytb.nex data/
cp -p 16s.nex data/
```

## Launching `RevBayes`

Launch `RevBayes` by typing `rb` when using the Docker container (or `./rb` if your are using the Terminal and you have not yet exported the path; you need the `rb` executable file inside `Lab_2` to do this!). This should launch `RevBayes` and give you a command prompt (the `>` character); this means `RevBayes` is waiting for input.

## Constructing the phylogenetic model *interactively*

### Reading the sequence data

We have special functions that read alignments in `.nexus` or `.fasta` formats (among others). We read the alignments of the *cytb* and *16s* genes using the `readDiscreteCharacterData` function:

```r
# Make sure you are in the correct directory
getwd()
# Read in cytb and 16S data
data_cytb = readDiscreteCharacterData("data/cytb.nex")
data_16s  = readDiscreteCharacterData("data/16s.nex")
```

We *concatenate* the two datasets into a single alignment. We also extract some useful information from the alignment that we will need later.

```r
# Concatenate them into one alignment
data = concatenate(data_cytb, data_16s)

# Get some useful information about the data
taxa = data.taxa()
num_taxa = data.ntaxa()
num_branches = 2 * num_taxa - 3 # 2s - (n-1)
num_sites = data.nchar()
```

<details>
<summary><b>TIP 1: cleaning the environment</b></summary>
<br>

You can use function `ls()` to see which objects you have created and are therefore part of your `RevBayes` environment. If you want a fresh start, type `clear()` to remove everything you have in the working environment. If you wanted to remove a spcific object (e.g., `data`), you would then type `clear(data)`.

</details>

<details>
<summary><b>TIP 2: you used methods `ntaxa` and `nchar` to access information about object `data`. How can you check other methods?</b></summary>
<br>

If you type the name of the object followed by `.methods()`, you will see a list of methods that you can use to extract information about such object. Given that our object is named `data`, we can type `data.methods()`, which prints on the screen a long list of methods that you can use! E.g.: you can use `chartype` to know the type of character data, but there will be other methods that you may not be able to use because they have not been defined for object `data`, such as `getEmpiricalBaseFrequencies`.

</details>

### Creating a vector of movement proposals for MCMC

**REMEMBER** that, in Bayesian Inference, a simulation approach called *Markov Chain Monte Carlo* is used to approximate the posterior probability of the phylogenetic model, as we cannot estimate this quantity analytically. To this end, a composite *continuous-time Markov Chain* process (`CTMC`) with as many variables as parameters in the model is constructed, which has as its stationary distribution the posterior probability we wish to estimate. Using *Monte Carlo* simulations coupled with the *Metropolis-Hastings* algorithm, we update starting random values for each parameter in such a way that we approximate the stationary distribution by maximizing the likelihood in each step of the `CTMC` (climbing the "mountain") but occasionally allowing for a decrease in the (ln) likelihood value.

To perform this *updating*, we need movement proposals for each parameter, whose type depend on the parameter itself, e.g., *sliding window* for uniform parameters, *scale values* for rate parameters. Each movement proposal is accompanied by a *weight*, a constant variable with an assigned fixed value, which determines how often the parameter is updated during the MCMC analysis: the higher the weight, the more frequent the movement.

First, we create an empty vector, called `move_index`, which we will populate with the different *movement proposals* we need for each parameter in the model. The alternative option is to define a *move* after we define a parameter, but using this vector allows us to keep track of how many moves we have to create.

```r
# Create a "move index" variable
move_index = 0
```

### Specifying the tree topology

We use a uniform prior on the tree topology, which implies that all topologies have the same prior probability (i.e., they are equally probable). To update the topology as we run the chain, we use two type of movements: *Nearest-Neighbor Interchange* (NNI) and *Subtree Pruning and Regrafting* (SPR).

We assign a large *weight* to this movement because the topology is a difficult parameter to estimate. The acceptance rate for topology proposals is low (c. 5%), compared to 20% for other parameters. So we put more effort on these movements and assign a larger weight. Therefore, we will spend more time updating the topology parameter (i.e., by doing NNI and SBR movement) than for any other parameter:

```r
# We assume a uniform prior on the tree topology
topology ~ dnUniformTopology(taxa)
moves[++move_index] = mvNNI(topology, weight=10.0)
moves[++move_index] = mvSPR(topology, weight=10.0)
```

<details>
<summary><b>TIP about moves</b></summary>
<br>

Functions which name start with `mv` refer to "moves" -- useful if you want to distinguish them from model objects, distributions (i.e, they start with `dn`), monitors, workspace objects, or other functions! You can find [a reference for the `Rev` language on the `RevBayes` website](https://revbayes.github.io/documentation/mvAddRemoveTip.html).

</details>
<br>

Now, you can see why we need an empty movement vector `move_index`. The command `++move_index` increases the value of `move_index` each time we use it, which makes it easy to add moves to the vector without remembering for ourselves how many moves we have included in our analysis (we can check at the end by typing the name of the variable to see its final value!).

### Specifying the branch lengths

Before we continue, let's specify a seed number in case we want to reproduce our results -- we will randomly draw some values, and only with a seed number you will be able to reproduce the results you get!

```r
# Set a seed number, e.g., 12345
seed(12345)
```

Now, we create a vector of branch lengths `br_lens`, one per branch in the phylogram, using a `for` loop. Each `br_lens[i]` is a stochastic variable, whose value is drawn from an exponential prior distribution with rate parameter 10 (this assigns a higher prior to shorter branch lengths). We specify a *scale* move on each `br_lens[i]`; this move multiplies or divides the parameter by a random number. We also keep track of the *tree length* (`TL`), a deterministic variable which is the sum of the branch lengths.

```r
# Create empty vector, which then will be filled with
# a random value sampled from an exponential distribution
# with lambda = 10
br_lens = rep(0,num_branches)
for(i in 1:num_branches){
  br_lens[i] ~ dnExponential(10.0)
  moves[++move_index] = mvScale(br_lens[i], weight=1.0)
}
TL := sum(br_lens)
```

<details>
<summary><b>QUESTION: what kind of variable is <code>TL</code>?</b></summary>
<br>

*ANSWER*: `TL` is a **deterministic** variable, which value will change depending on the sum of the values present in vector `br_lens`. If the value of the elements in vector `br_lens` are updated, the value of `TL` will also change!

</details>

<details>
<summary><b>QUESTION: how would you check that you can obtain the same vector of branch lengths if you re-run again the code above?</b></summary>
<br>

*ANSWER*: You would need to use the same seed number again and re-run the command:

```r
seed(12345)
br_lens = rep(0,num_branches)
for(i in 1:num_branches){
  br_lens[i] ~ dnExponential(10.0)
}
```

We are not adding the `moves[++move_index] = mvScale(br_lens[i], weight=1.0)` because you would then append again the same information while increasing the value of `move_index`!

</details>

### Creating the phylogram

A "phylogram" is a tree with branch lengths measured in the expected number of substitutions. We create a deterministic variable `phylogeny` to wrap the topology and branch lengths together into a phylogram using the function `treeAssembly`. Notice that, because this is a deterministic node, we do not need to define movement proposals, as we did for the stochastic variables `br_lens` and `topology`.

```r
phylogeny := treeAssembly(topology, br_lens)
```

### Specifying the substitution model

The last component of the model is the substitution model (the `Q matrix`), which comprises two different types of parameters: the *exchangeability rates* (`er`) and the *stationary frequencies* (`pi`). In this analysis, we will use the *GTR* substitution model, in which there are six rates and four frequencies, 10 stochastic parameters. Notice that, in a *GTI* (time-irreversible) model, there would be four frequencies but 12 rates.

We assign a prior *Dirichlet* distribution to the stationary frequencies, a multinomial distribution in which each frequency has its own prior but the sum of priors equals to 1. Below, all priors are made equally probable. We assign the same type of Dirichlet prior to the rate parameters. Each of these priors is updated simultaneously in the same movement proposal.

Finally, we construct a deterministic variable, the `Q matrix` by wrapping together the `er` and `pi` parameters using the function `fnGTR`.

```r
# The `dnDirichlet` function will generate a random
# draw from a Dirichlet distribution
seed( 12345 )
pi ~ dnDirichlet(v(1,1,1,1))
# Check that the stationary frequencies indeed add up to 1
sum(pi)
# Add the move for the stationary frequencies
moves[++move_index] = mvDirichletSimplex(pi, weight=1.0)
seed( 12345 )
er ~ dnDirichlet(v(1,1,1,1,1,1))
# Add the move for the stationary frequencies
moves[++move_index] = mvDirichletSimplex(er, weight=1.0)

Q := fnGTR(er, pi)
```

### Specifying the likelihood function for the `CTMC` process

We construct a stochastic node, the `seq` variable, and assign it a prior that is updated using the `dnPhyloCTMC` distribution; this function takes as arguments the *phylogeny* and *Q matrix* variable values. We need to specify the type of data (*DNA*) because a CTMC can also be used with morphological data.

We them "clamp" the seq variable to the observed data, i.e., the alignment. This tells `RevBayes` to treat the random variable as an observation.

```r
# Get our `seq` variable
seq ~ dnPhyloCTMC(tree=phylogeny, Q=Q, type="DNA")
# Attach observed data
seq.clamp(data)
```

> [!NOTE]
>
> If we want to sample from the prior, we need to comment out `seq.clamP(data)`, the last line in the code above.

### Running the analysis

To run the MCMC analysis, we wrap up the model object `my_model`, as dependent on stochastic variable *Q*.

```r
#########################
# Make the model object #
#########################

my_model = model(Q)
```

Define monitors that will print to the screen the results and also print to a file (the most important). There are two types of files: `bufo.log` will print the parameter values; `bufo.trees` will print the trees. We decide how often these parameters are printed with the `printgen` command.

```r
#####################
# Make the monitors #
#####################

monitors[1] = mnModel(filename="output/bufo.log",printgen=100, separator = TAB)
monitors[2] = mnFile(filename="output/bufo.trees",printgen=100, separator = TAB, phylogeny)
monitors[3] = mnScreen(printgen=100, TL)
```

Create an MCMC analysis object with the number of generations (number of steps in the CTMC) to run.

```sh
################
# Run the MCMC #
################

analysis = mcmc(my_model, monitors, moves)
analysis.run(generations=100000)
```

> [!NOTE]
>
> This analysis takes 00:01:11 to run on the following specs:
>
> * Processor: 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz | 4 cores, 8 logical processors
> * RAM: 32Gb
> * OS: Microsoft Windows 11 Pro, but all analyses were ran under a Windows Subsystem for Linux (WSL)
>   * Details about the WSL used: Ubuntu 22.04.4 LTS

### Summarizing the tree

Finally, we summarize the marginal distribution of trees by building the MAP (*maximum a posteriori*) tree, which is the tree topology that has the highest posterior probability, and computing the posterior probabilities for each node in the MAP tree.

```sh
# start by reading in the tree trace
treetrace = readTreeTrace("output/bufo.trees", treetype="non-clock")
map_tree = mapTree(treetrace,"output/bufo_MAP.tree") 

# exit the program
q()
```

## Running the analysis in script mode (inside `RevBayes`)

If your want to run the analysis above without typing every command at the `RevBayes` prompt, you can source the script, as we learnt in *Lab_1*. Launch Source the `my_phylogenetic_analysis.Rev` script, which contains all commands above (OBS!! Remember the quotation marks!).

```r
source("my_phylogenetic_analysis.Rev")
```

----

<details>
<summary><b>Notes from previous editions when using an HPC (please ignore, only here for the record)</b></summary>
<br>

Finally, we can use a bash file if we are running the script within the cluster. Below is an example of a bash file to run the script `my_phylogenetic_analysis.Rev`. Because we are running in a cluster, we need to include a command for the output to be saved. You can find this script `myScript-cluster.sh` inside `Lab_2` folder.

```sh
#!/bin/bash

#SBATCH -p normal
#SBATCH -n 8
#SBATCH -c 1
#SBATCH --mem=6GB
#SBATCH --job-name orthofinder-job01
#SBATCH -o %j.out
#SBATCH -e %j.err

module load revbayes

mpirun -np 8 rb-mpi my_phylogenetic_analysis.Rev
```

</details>

----

## Visualizing the phylogeny and clade support

Once we quit `RevBayes`, we can visualize the output: the phylogeny and the clade statistical support (the *nodal posterior probabilities*), using the software `FigTree` ([download via this link](http://tree.bio.ed.ac.uk/software/figtree/)) or `TreeViewer` ([download via this link](https://treeviewer.org/)). Open the file `bufo.trees` using your preferred graphical interface and check clade support by doing the following:

* `FigTree`: click on *node labels: posterior* on the left panel.
* `TreeViewer`:
  * Click on `Modules > Plot actions`. You will see that there are two attributes: `Branches` and `Labels`.
  * Expand button `Labels` and select `Support`. Then select `Show on: Internal nodes`. You can click `Font` under `Appearance` to decrease the size if it is too large!
  * Now, add another attribute to bring back taxa names (i.e., click on `+ Add module` and select `Labels`). You can decrease the font size as aforementioned if required.
  * To add a more visual label, you can click the button `Add module` and select `Node shapes`. You can then customise the node shapes and make the colour represent the bootstrap values by doing the following:
    * Select `Show on: Internal nodes` so that the colour matches the support value.
    * Change the shape to `Circle` under `Appearance`.
    * Disable `Auto fill colour by node`.
    * Click the wrench button next to the blue square for button `Fill colour` and now type `Support` in the first box for `Attribute name` and chang ethe `Attribute type` to `Number`.
  * If you want to change the tree display, go to the `Coordinates modules` (button on the left hand side to the `Plot elements` button you were using), and then update it.

## Evaluating stationarity and mixing of parameters

We can also evaluate how well our MCMC analysis approximated the posterior distribution of each parameter in the model by using the software `Tracer` ([download via this link](https://beast.community/tracer)). Download `Tracer` on your PC and open it by double clicking: it is a graphical programme. Use *Import Trace File* from the `Tracer` menu to read the output file `bufo.log`. Check the shape of the posterior distributions, the ESS values (should be > 200), and search for potential correlations between parameters.

----

## Exercises

1. Repeat the above Bayesian phylogenetic analyses but now using the three alignments for the *Viburnum* dataset located at the `Lab_2` directory, which are named `matK.nex`, `ITS.nex`, and `trnS-G.nex`. Inspect the posterior probabilities in `FigTree` or `TreeViewer`. How do the support values compare to those you got for the *Bufo* phylogeny?
2. How well did the above MCMC perform? Are the ESS values for all of the continuous parameters greater than 200?
3. Run your *Viburnum* analysis again or compare your tree with its posterior probabilities to those of your neighbor. Are they similar or different? If they are different, can you hypothesize why they might be different?
4. (Optional) Try setting up an analysis of the *Viburnum* dataset where each sequence gets its own *Q matrix*, but all share the same topology and branch lengths. You can accomplish this by creating multiple *Q* matrices and `seq` objects, each corresponding to a different gene region. Can you express this model in graphical form?
