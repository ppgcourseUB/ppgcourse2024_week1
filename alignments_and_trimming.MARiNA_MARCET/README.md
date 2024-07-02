# MULTIPLE SEQUENCE ALIGNMENTS AND TRIMMING

**Instructor**: Marina Marcet-Houben

The objective of this practice is to explore different multiple sequence alignments tools and check how they can affect the reconstruction of a phylogenetic tree. We will also discuss the effects of trimming alignments.

***

## Link to Presentation

[Presentation](https://docs.google.com/presentation/d/1HmnqLNyCuM_ZkzaTzt67rIOs75Ww2qw9jlJAAh18Lkc/edit?usp=sharing)

***

## Software description and hints

For this practice we will use three different alignment programs: [MUSCLE](https://www.drive5.com/muscle/), [MAFFT](https://www.ebi.ac.uk/jdispatcher/msa/mafft) and [PRANK](http://wasabiapp.org/software/prank/). 

We will also use a tool for trimming alignments: [trimAl](https://vicfero.github.io/trimal/).

To check the effect of alignment reconstruction on phylogenetic tree inference we will use [fasttree](http://www.microbesonline.org/fasttree/)

***

## Data description and access

We will use three files containing 13 sequences of different vertebrates each. The sequences have been chose so that each dataset has a different average identity:

* High average identity: identity > 90%
* Median average identity: identity ~ 65%
* Low average identity: identity < 40%

You can find the three files in the folder data/

***

## Step 1

Choose one of the datasets, for instance the medium_average identity dataset, and then run the three different alignment programs on it.

A.- To execute MUSCLE run the command like this:

```bash
muscle -in median_average_identity.fa -out median_average_identity.muscle.alg
```

B.- To execute MAFFT run the command like this:

```bash
mafft median_average_identity.fa >median_average_identity.mafft.alg
```

C.- To execute PRANK run the command like this:

```bash
prank -d=median_average_identity.fa -o=median_average_identity.prank
```

<i>Note that prank will change your output name to median_average_identity.prank.best.fas</i>

Alternatively you can use a for loop to analyse all three files at the same time. See here for an example using MUSCLE but it would be the same for the two other programs

```bash
for i in $(ls *fa);do muscle -in $i -out $i.muscle.alg;done
```


## Step 2

Use an alignment visualization tool to check out your three alignments. This can be done in different ways, but here are some recomendations:

* [Aliview](https://ormbunkar.se/aliview/)
* [Seaview](https://doua.prabi.fr/software/seaview)
* [JalView](https://www.jalview.org/jalview-js/) - Go to JalviewJS and choose the option launch JalviewJS in the menu

Alternatively, trimal can also print through the command line a view of the alignment that can give you an idea on how your alignment looks like

```bash
trimal -in median_average_identity.prank.best.fas -phylip
```
Once you have checked out your three alignments, try to answer these questions:

```diff
Question 1: Do the alignment programs give different alignments? (Note that the order of the sequences in the alignment is not relevant in this case)
Question 2: Can you identify any other trend that could differentiate the programs?
Question 3: What about the time it takes to run each program, could that be a problem with larger datasets?
```

## Step 3

Now generate a trimmed alignment for the alignment reconstructed with prank by running trimal. We will use the different trimming strategies that are implemented in the program. Pay particular attention on the number of aa remaining in the alignment after each execution of trimal.

A.- Use trimAl with the gappyout approach

```bash
trimal -in median_average_identity.prank.best.fas -out median_average_identity.prank.gappyout -gappyout
```

B.- Use trimAl with the automated1 approach

```bash
trimal -in median_average_identity.prank.best.fas -out median_average_identity.prank.automated1 -automated1
```

C.- Use trimAl with a manual approach deciding the percentage of the alignment you want to keep (-cons) and the percentage of gaps per column you want to keep in your alignments (-gt)

```bash
trimal -in median_average_identity.prank.best.fas -out median_average_identity.prank.manual -gt 0.9 -cons 30 
```

```diff
Question 1: Does the trimming have any effect on the alignment?
Question 2: Do the different trimming strategies give different results?
Question 3: Of all the alignments we have reconstructed, which is the best one?
```

## Step 4

Optional - Run Fasttree on your alignments to obtain a phylogenetic tree for each of them. Then compare the topologies to infer which is the best alignment.

![species_tree_image](https://github.com/ppgcourseUB/ppgcourse2024_week1/assets/9434530/4d71b80d-86d2-42b7-a9ac-a37a647efec1)

To run Fasttree make sure your alignment is in fasta format and then execute:

```bash
fasttree median_average_identity.prank.best.fas > median_average_identity.prank.best.nw
```

You can now visualize the tree by opening the file median_average_identity.prank.best.nw, copying the text in there and pasting it in [phylo.io](https://phylo.io/). Phylo.io is a lightweight tree visualizer that allows you to check out trees in an easy way. 

