# Data collection and parsing

## 1. Obtaining and formatting raw sequence data

We will download the following CYTB sequences from the NCBI web server and save them in FASTA format by using the following notation for the file name: `genus_species_cytb.fasta`. Specifically, we will use the first 3 letters of the genus and the first three letters of the species. Please follow the links below to download the corresponding sequences:

* [*Ailuropoda_melanoleuca*, NCBI RefSeq: NC_009492.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_009492.1?from=15529&to=16668&report=fasta): file saved as [`ail_mel_cytb.fasta`](ind_cytb/ail_mel_cytb.fasta).
* [*Tremarctos_ornatus*, NCBI RefSeq: NC_009969.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_009969.1?from=15030&to=16169&report=fasta): file saved as [`tre_orn_cytb.fasta`](ind_cytb/tre_orn_cytb.fasta).
* [*Helarctos_malayanus*, NCBI RefSeq: NC_009968.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_009968.1?from=15054&to=16193&report=fasta): file saved as [`hel_mal_cytb.fasta`](ind_cytb/hel_mal_cytb.fasta).
* [*Ursus_americanus*, NCBI RefSeq: NC_003426.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_003426.1?from=15113&to=16252&report=fasta): file saved as [`urs_ame_cytb.fasta`](ind_cytb/urs_ame_cytb.fasta).
* [*Ursus_thibetanus*, NCBI RefSeq: NC_008753.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_008753.1?from=15139&to=16278&report=fasta): file saved as [`urs_thi_cytb.fasta`](ind_cytb/urs_thi_cytb.fasta).
* [*Ursus_arctos*, NCBI RefSeq: NC_003427.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_003427.1?from=15306&to=16445&report=fasta): file saved as [`urs_arc_cytb.fasta`](ind_cytb/urs_arc_cytb.fasta).
* [*Ursus_maritimus*, NCBI RefSeq: NC_003428.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_003428.1?from=15301&to=16440&report=fasta): file saved as [`urs_mar_cytb.fasta`](ind_cytb/urs_mar_cytb.fasta).
* [*Melursus_ursinus*, NCBI RefSeq: NC_009970.1](https://www.ncbi.nlm.nih.gov/nuccore/NC_009970.1?from=15086&to=16225&report=fasta): file saved as [`mel_urs_cytb.fasta`](ind_cytb/mel_urs_cytb.fasta).

Now, we need to process the raw data we will have just downloaded! We will concatenate all the [sequences we have downloaded and saved them as a unique FASTA file in directory `ind_cytb`](ind_cytb) (see links provided above). In order to do this, we can run the following code from directory `data_processing`:

```sh
## Run from directory `data_processing`
for i in ind_cytb/*fasta
do
name=$( echo $i | sed 's/..*\///' | sed 's/\_cytb..*//' )
sed 's/^>..*/\>'${name}'/' $i >> ind_cytb/unaln_raw.fasta
done 
```

Now, we will generate a one-line FASTA file that is easier to parse:

```sh
## Run from directory `data_processing`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
mkdir unaln_seq
../src/one_line_fasta.pl ind_cytb/unaln_raw.fasta
name1=$( echo ind_cytb/unaln_raw.fasta | sed 's/\.fasta//' )
name2=$( echo $name1 | sed 's/..*\///' )
mv $name1"_one_line.fa" unaln_seq/$name2".fasta"
```

## 2. Inferring alignment and phylogeny

### Alignment and tree inference

#### 1. Bayesian approach to co-infer alignment and tree (`BAli-Phy`)

We can run `BAli-Phy` ([Redelings 2021](https://doi.org/10.1093/bioinformatics/btab129)) to co-infer phylogeny + alignment under a Bayesian framework given that the alignment is not too big (make sure you have installed this program before you continue!). All the diagnostics and summary reports have been generated following the [`BAli-Phy` tutorials and recommendations](https://www.bali-phy.org/README.html#output). You can get started by following the next code snippet:

```sh
## Run from directory `data_processing`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
mkdir -p aln_seq/baliphy
cd aln_seq/baliphy
mkdir -p baliphy
cd baliphy
bali-phy ../unaln_raw.fasta -S hky85+Rates.gamma[5] -n cytb & # this will create a dir called `cytb_r1-1`
bali-phy ../unaln_raw.fasta -S hky85+Rates.gamma[5] -n cytb & # this will create a dir called `cytb_r1-2`

# Text written based on the BAli-Phy manual: https://www.bali-phy.org/README.html#mixing_and_convergence
# We can explore whether the chains may have converged by computing the ASDSF and the MSDFSF
#  - The SDSF value is the SD across runs of the posterior probabilities (PP) for that split.
#    By averaging the SDSF values across splits, we obtain the ASDSF value (Huelsenbeck and Ronquist, 2001).
#    An acceptable value of the ASDSF is < 0.01.
#  - The maximum of the SDSF values is the MSDSDF, which represents the range of variation in PP across 
#    the runs for the split with the most variation.
trees-bootstrap cytb-1/C1.trees cytb-2/C1.trees > partitions_bs.txt
##> Our results show the following:
##> ASDSF[min=0.100] = 0.007     MSDSF = 0.020
##>
##> In that way, we may say that there are chances our chains have reached convergence. Nevertheless, we will
##> run another diagnostic.
#
# We will calculate potential scale reduction factors (PSRF) to check that different runs have similar 
# posterior distributions. Only numerical variables may have a PSRF.
# The PSDRF is a ratio of the width of the pooled distribution to the average width of each distribution,
# and ideally should be 1. The PSRF is customarily considered to be small enough it is is less than 
# 1.01.
# The command below will report the following:
# - PSRF-80%CI: PSRF based on the length of 80% credible intervals (Brooks and Gelman 1998).
# - PSRF-RCF: for each individual distribution, the 80% credible interval is found. Then, the probability
#   of that interval (which may be more than 80%) is divided by the probability of the same interval under
#   the pooled distribution. 
# 
# This diagnostic can detect when a parameter value has stabilized at different values in several independent
# runs, indicating a lack of convergence. This situation might occur if different runs of the Markov chain were
# trapped in different modes and failed to adequately mix between modes.
statreport cytb-1/C1.log cytb-2/C1.log > report_PSRF.txt
##> Our results are the following:
##>  Ne  >= 240    (posterior)
##>  min burnin <= 248    (rs07:mean_length)
##>  PSRF-80%CI <= 1.007    (hky85:pi[C])
##>  PSRF-RCF <= 1.01    (hky85:pi[A])
##>
##> The PSRF is less than 1.01, and thus we can say that this check has been passed!
##>
##> It seems both diagnostics show that chances are our chains have reached convergence. Therefore, we will stop
##> our runs now.
```

Once you have checked for convergence and it seems it is time to stop them, you can find their PID number and kill the jobs (i.e., run from the terminal `kill -9 PID`). To summarise the results, we can run the following commands:

```sh
# We will generate the greedy consensus tree as the tre is fully resolved.
# We will run the following options:
# `-s 10%` Skip the first 10% of tree
# `--greedy-consensus`
#
# Run from directory `baliphy`
trees-consensus -s 10% cytb-1/C1.trees cytb-2/C1.trees --greedy-consensus=cytb_greedy_bp.tree
# We can also check topology convergence
trees-bootstrap cytb-1/C1.trees cytb-2/C1.trees > convergence_treetopo.txt

# Now, we can compute the alignment using posterior decoding
cut-range  cytb-1/C1.P1.fastas cytb-2/C1.P1.fastas --skip=100 | alignment-chop-internal --tree cytb_greedy_bp.tree | alignment-max > P1-max.fasta

# Last, we will write a summary output
# in HTML format
# Run also from `baliphy` dir
bp-analyze cytb-1 cytb-2
```

We can now open the file [`cytb_greedy_bp.tree`](aln_seq/baliphy/cytb_greedy_bp.tree) with `FigTree` to visualise the inferred tree topology. We will root the tree at *ail_mel* (i.e., *Ailuropoda_melanoleuca*). We will now select option `Ordering: increasing` after ticking the box `Trees> Order nodes`. In that way, we will be able to observe the tree topology without branch lengths, which shall match the next topology in Newick format:

```text
((((((urs_ame,urs_thi),hel_mal),(urs_arc,urs_mar)),mel_urs),tre_orn),ail_mel);
```

Now, we will export the rooted tree. First, we shall click `File> Expot Trees>`, then select `Newick` in the `Tree file format` box, tick the box `Save as currently displayed`, and then we shall save the rooted tree with branch lengths as `cytb_rooted_bl.tree` inside directory `baliphy`.

#### 2. Heuristics for alignment inference (`mafft`) and maximum likelihood for phylogeny inference (`RAxML-NG`)

First, given that we have a very small dataset, we can run either `mafft` ([Katoh 2013](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3603318/)) or `muscle5` ([Edgar 2022](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC9664440/)) with the automatic commands (make sure you have installed these programs before you continue!). If you had a larger alignment, you may want to try other algorithms to speed up alignment inference. You can run both aligners and then compare the output:

```sh
## Run from directory `data_processing`
# You should still be in directory `baliphy`, so
# we will change directories first. If you 
# are already in `data_processing`, please ignore
# the first command that changes directories!
cd ../../
mkdir -p aln_seq/{mafft,muscle5}
cd aln_seq/mafft 
mafft --auto ../../unaln_seq/unaln_raw.fasta > cytb_aln_mafft.fasta
cd ../muscle5
muscle5.1 -align ../../unaln_seq/unaln_raw.fasta -output cytb_aln_muscle5.fasta
```

Given that both aligners have inferred the same alignment, then we can proceed with `RAxML-NG` ([Kozlov 2019](https://academic.oup.com/bioinformatics/article/35/21/4453/5487384)) to infer the best-scoring maximum-likelihood (ML) tre (make sure you have installed this program before you continue!):

```sh
## Run from directory `data_processing`
# You should still be in directory `muscle5`, so
# we will change directories first. If you 
# are already in `data_processing`, please ignore
# the first command that changes directories!
cd ../../
mkdir tree
cd tree
raxml-ng --msa ../aln_seq/muscle5/cytb_aln_muscle5.fasta --model HKY+G5 --prefix cytb --threads 2 --seed 12345 --tree pars{25},rand{25}
```

We can now open the file [`cytb.raxml.bestTree`](tree/cytb.raxml.bestTree) with `FigTree` to visualise the inferred tree topology. We will root the tree at *ail_mel* (i.e., *Ailuropoda_melanoleuca*). As some branch lengths seem to have length 0, we will select option `Ordering: increasing` after ticking the box `Trees> Order nodes` and then option `Transform: cladogram` after ticking the box `Trees>Transform branches`. In that way, we will be able to observe the tree topology without branch lengths, which shall match the next topology in Newick format:

```text
((((((urs_thi,urs_ame),hel_mal),(urs_arc,urs_mar)),mel_urs),tre_orn),ail_mel);
```

Now, we will untick the box `Transform branches` and export the rooted tree. First, we shall click `File> Export Trees>`, then select `Newick` in the `Tree file format` box, tick the box `Save as currently displayed`, and then we shall save the rooted tree with branch lengths as `cytb_rooted_bl.tree` inside directory `tree`.

----

You can see that we have inferred the same molecular alignment and tree topology regardless the approach chosen. Sometimes, however, that may not be the case and you will need to carry out further diagnostics. For this tutorial, however, we can now proceed to further format these input files for timetree inference!

----

## 3. Data formatting

Before proceeding with timetree inference, we need to make sure that:

1. The alignment file is in PHYLIP format and easy to read (i.e., ideally one sequence per line).
2. The tree file is in Newick format.

Before getting started, we will copy the input files that we have generated when processing the raw data to a new directory called `00_aln_trees_raw`. We will use the output files generated by `BAli-Phy` given that (i) the alignment has a one-line FASTA format per sequence and that (ii) there are no branch lengths close to 0 in the inferred phylogeny:

```sh
## Run from directory `data_processing`
# You should still be in directory `tree`, so
# we will change directories first. If you 
# are already in `data_processing`, please ignore
# the first command that changes directories!
cd ../
mkdir -p 00_aln_trees_raw/{aln,tree}
cp aln_seq/baliphy/P1-max.fasta 00_aln_trees_raw/aln/cytb_aln.fasta
cp aln_seq/baliphy/cytb_rooted_bl.tree 00_aln_trees_raw/tree
# We will need to remove the blank lines and other 
# trail characters that are included in the output file
# generated by `BAli-Phy` or we may have problems when
# processing our this FASTA file later!
sed -i '/^$/d' 00_aln_trees_raw/aln/cytb_aln.fasta
sed -i 's/\r//g' 00_aln_trees_raw/aln/cytb_aln.fasta
sed -i 's/\M//g' 00_aln_trees_raw/aln/cytb_aln.fasta
sed -i 's/   //g' 00_aln_trees_raw/aln/cytb_aln.fasta
```

Now, we are ready to start!

### Alignment file

If you open [the alignment file](00_aln_trees_raw/aln/cytb_aln.fasta), you will see that each aligned sequence is already in a unique line, which makes it easier to convert into PHYLIP format. If that was not the case, remember that you can always use various tools such as [this in-house PERL script called `one_line_fasta.pl`](../src/one_line_fasta.pl). In essence, this PERL script will convert an alignment where the sequences for each taxon are split into more than one line into an alignment where each line has a sequence such as [our input alignment file](00_aln_trees_raw/aln/cytb_aln.fasta).

Now, we need to run [an in-house PERL script called `FASTAtoPHYL.pl`](../src/FASTAtoPHYL.pl) to generate an alignment in PHYLIP format:

```sh
## Run from `00_aln_trees_raw/aln`
# You should still be in directory `data_processing`, so
# we will change directories first. If you 
# are already in `00_aln_trees_raw`, please ignore
# the first command that changes directories!
cd 00_aln_trees_raw/aln
aln_name=`ls *aln.fasta`
a_noext=$( echo $aln_name | sed 's/\.fasta//' )
num=$( grep '>' $aln_name | wc -l )
len=$( sed -n '2,2p' $aln_name | sed 's/\r//' | sed 's/\n//' | wc -L )
perl ../../../src/FASTAtoPHYL.pl $aln_name $num $len 
# Create a directory for input data for `MCMCtree`
mkdir ../../01_inp_data
mv $a_noext.phy ../../01_inp_data/aln_123CP.phy
```

You will now see a new directory called `01_inp_data` inside the directory [`00_data_formatting`](README.md). If you navigate to this newly created `01_inp_data` directory, you will find the alignment in PHYLIP format (i.e., the input file we need!). You will also find a log file called `log_lenseq.txt` inside the `00_aln_trees_raw` directory where you can read how many taxa were parsed and the length of each sequence.

Now, we can also partition our dataset according to a codon partitioning scheme. As it is widely known, first-codon positions and second-codon positions within a gene are expected to evolve in a more similar manner when compared to third-codon positions. The latter tend to evolve much faster than first- and second-codon positions, and thus have a much higher transition:transversion bias due to the fact that most of transversions are nonsynonymous for the third-codon positions ([Bofkin and Goldman, 2006](https://academic.oup.com/mbe/article/24/2/513/1150702)). In that way, we will evaluate the impact that codon partitioning scheme (CP scheme) can have on divergence times estimation by using three alignments:

* **All codon positions (123CP)**: one alignment block with one gene alignment with all codon positions.
* **Only first and second codon positions (12CP)**: one alignment block with only the first and the second codon positions.
* **Partitioned alignment (12CP-3CP)**: one alignment block with only the first and the second codon positions and a second alignment block with only the third codon positions.

We will use [the `fasta-phylip-partitions` pipeline](https://github.com/sabifo4/fasta-phylip-partitions), a tool I wrote some time ago, to generate CP-partitioned alignments. To make things easy, I have compressed this tool and saved it in the [`src`](../src/) directory. You just need to run the next commands to partition the dataset:

```sh
## Run from directory `src` to uncompress the file
# You should still be in directory `00_aln_trees_raw/aln`,
# so we will change directories first. If you 
# are already in `00_aln_trees_raw`, please ignore
# the first command that changes directories!
cd ../../../src/
tar -xvf fasta-phylip-partitions.tar.gz
chmod 775 fasta-phylip-partitions/src/*sh
chmod 775 fasta-phylip-partitions/src/Tools/*
# Now, change to `00_aln_trees_raw/01_inp_data` and run the following
# code to prepare the input data for the pipeline
cd ../data_processing/00_aln_trees_raw/aln
mkdir part_scheme
cd part_scheme
grep '>' ../cytb_aln.fasta | sed 's/>//' > species_names.txt
cp ../cytb_aln.fasta .
# Now, run the pipeline. In essence, the first argument is the current 
# directory ("."), the second argument the tag ID for the job
# ("cytb"), and then a tag specifying if the alignment 
# needs to be partitioned into CPs, which we do want, and hence use 
# "partY".
# If you do not have this pipeline on your system, you can
# run the code below as it is using the source code that has already
# been added in the `src` directory. For more details about 
# how to use this pipeline, you can find this in the
# following link: https://github.com/sabifo4/fasta-phylip-partitions/blob/main/README.md
# NOTE: If you are running this code in a directory that you have synched to Dropbox or another 
# cloud storage and you have issues, just move the folder out of the synched directory and run the 
# command below again
../../../../src/fasta-phylip-partitions/src/Run_tasks.sh . cytb partY
# Move alignment with only 1st+2nd CPs to dir `01_inp_data`
cp phylip_format/02_concatenated_alignments/part12/part12_cytb_concat.aln ../../../01_inp_data/aln_12CP.phy
# Create partitioned alignment with two alignment blocks (1st+2nd CPs | 3rd CPs) in dir
# `01_inp_data
cat phylip_format/02_concatenated_alignments/part12/part12_cytb_concat.aln > ../../../01_inp_data/aln_12CP3CP.phy
printf "\n\n" >> ../../../01_inp_data/aln_12CP3CP.phy
cat phylip_format/02_concatenated_alignments/part3/part3_cytb_concat.aln >> ../../../01_inp_data/aln_12CP3CP.phy
```

Now, we have generated the three alignments that we will use in our timetree inference analysis, so we are ready to parse the tree file!

### Tree file

#### Calibrating the tree topology

The input tree file needs to be in PHYLIP format too, and we will also need to calibrate it! We will first remove the branch lengths and generate a PHYLIP formatted file with only the tree topology:

```sh
## Run from directory `00_aln_trees_raw/tree`
# You should still be in directory `part_scheme`,
# so we will change directories first. If you 
# are already in `00_aln_trees_raw`, please ignore
# the first command that changes directories!
cd ../../tree
printf "8  1\n" > tree_nobl.tree
sed 's/\:[0-9]*\.[0-9]*//g' cytb_rooted_bl.tree  >> tree_nobl.tree
```

Now, we are ready to calibrate the tree topology according to the following interpretation of the fossil record:

* **Caniformia**: given that we do not have a specific calibration for arctoids, we will calibrate the root of our phylogeny with the divergence of canids (dogs) and arctoids (musteloids, ursids, pinnipeds). The minimum age is 37.71 Ma and the maximum age is 66.09 Ma. The fossil taxon and specimen is *Hesperocyon gregarius* (SMNH P1899.6; 54) from the Cypress Hills Formation, Duchesnian NALMA, Lac Pelletier local fauna, Saskatchewan. In `MCMCtree` format and using a time unit of 100 Ma: `B(0.3771,0.6609)`.
* **Crown group Ursinae**: the oldest first appearance of a crown group bear in our dataset is *Ursus americanus* around 1.84 Ma. We will use this age as a minimum constrain for that clade. In `MCMCtree` format and using a time unit of 100 Ma: `L(0.0184)`.

We will run the R script [`Include_calibrations.R`](calibs/scripts/Include_calibrations_MCMCtree.R) to generate the calibrated tree files, which will be saved in the `01_inp_data` directory. Note that this script will require not only the tree file without branch lenghts, but also a converter file that matches the node age constraints specified by the user with specific node ages in the tree topology to be calibrated: the [`calibrations.txt` file](calibs/raw_calibs/calibrations.txt). This file follows a specific format:

* Header.
* One row per calibration.
* No spaces at all, semi-colon separated.
* There are 4 columns:
  * Name you want to give to the calibrated node (no spaces!).
  * Name of one of the tips (e.g., tip 1) that leads to MRCA (no spaces!).
  * Name of the other tip (e.g., tip 2) that leads to MRCA (no spaces!).
  * Calibration in `MCMCtree` notation (no spaces!). More details on the `MCMCtree` notation you need to use in the fourth column in [the PAML documentation](https://github.com/abacus-gene/paml/blob/master/doc/pamlDOC.pdf).
* The last line needs to be a blank line.

I have already provided you with the input file in the correct format, but the information above is relevant if you want to build your own calibration file in the future! Now that we have everything ready, we can run the R script [`Include_calibrations.R`](scripts/Include_calibrations.R). You will see that now three new files appear in directory `01_inp_data`:

* `cytb_calib_MCMCtree.tree`: this is the calibrated input file in `MCMCtree` notation. We will use it during timetree inference!
* `cytb_fordisplay_calib_MCMCtree.tree`: this is an additional file that you can use in `TreeViewer` or `FigTree` to display the calibrated tree file.
* `cytb_unclib.tree`: this is an uncalibrated file, which we will use when running `BASEML` to infer the branch lenghts, the gradient, and the Hessian; which are the two vectors and matrix, respectively, that `MCMCtree` will subsequently use to approximate the likelihood calculation ([dos Reis and Yang, 2011](https://doi.org/10.1093/molbev/msr045)).

#### Estimating the mean evolutionary rate

In order to build our gamma distribution for the rate prior, we shall consider the tree height (molecular distance in substitutions per site) and the divergence time at the root of the phylogeny (in time unit). As the [tree file we inferred with BAli-Phy](00_aln_trees_raw/tree/cytb_rooted_bl.tree) has information about the branch lengths, we can load this file in `R` to estimate the tree height. We also have the root calibration in the calibrated tree file that we have just generated, which can be used as a rough approximation of the age of the root of the phylogeny based on the fossil record. As we are using a soft-bound calibration density, the mean root age is the average between the minimum and the maximum ages used to constrain the root age (i.e., $(0.3771-0.6609)/2=0.519$, when time unit is 100 Ma).

We will use a vague shape ($\alpha=2$) to build our gamma distribution (i.e., rate prior) so that we can account for the uncertainty on the mean rate we have just estimated. If we had more knowledge on the mean rate, however, we should use a narrower prior with a larger $\alpha$ that better represents our prior information. Given that we have the mean evolutionary rate and parameter $\alpha$, we have everything we need to calculate the $\beta$ parameter of the Gamma distribution. I have written the [R script `calculate_rateprior.R`](00_aln_trees_raw/tree/scripts/calculate_rateprior.R) to carry out all the tasks mentioned above. You can open this file in RStudio to find out the value of $\beta$ for each analysis depending on the root calibration being used, and plot the final prior on the rates. A summary of what you will find in the script is described below:

```text
First, we know that the molecular distance (tree height, distance from the root to present time) is equal to the mean evolutionary rate (in substitutions per site per year) times the age of the divergence time at the root (in time unit, which we can define later). If we have estimated our phylogeny, and therefore have estimated the branch lengths, we will be able to estimate the tree height. The units of the tree height will be the following:

tree_height = rate * root_age --> units_tree_height = subst/site/y * y = subst/site

One way of estimating the tree height is by using the R function `phytools::nodeHeights`. The maximum height calculated by this function corresponds to the length from the root to the heighest tip. 

After estimating the tree height of our phylogeny (in subst/site) and considering the age of the root based on fossils (time unit = 100 Ma), we can get a rough estimate of the mean rate depending. We will calculate the mean rate using two different time units:

Time unit = 100 Ma (mean root age in Ma) --> mean_rate = tree_height / root_age = (subst/site) / (Ma) = subst/site per time unit (time unit = 100 Ma = 10^8 years)  --> (subst/site)/10^8 years

We also know that the mean of the gamma distribution is our parameter of interest: the mean evolutionary rate. Therefore:

mean_G = mean_rate = alpha / beta 
Time unit = 100 Ma: mean_rate = alpha / beta --> beta = alpha / mean_rate = 2 / mean_rate

In that way, the calibrated tree should be in this time unit too (i.e., do not forget to scale the calibrations accordingly if needed!). 
```

If you run the [R script `calculate_rateprior.R`](scripts/calculate_rateprior.R), you will see how all the steps described above take place and a new PDF file with the prior distribution to be used in each analysis will be generated in a new directory called `out_RData` inside the `tree` directory.

A [template control file](template_ctl/tmp_paml.ctl) with the $\alpha$ and $\beta$ parameters (as defined using the R script above) for the gamma distribution as a prior on the rates has also been generated and saved in a directory called [`template_ctl`](template_ctl) inside directory `data_processing`. Note that several options will be subsequently modified to fit the analysis with this dataset (i.e., you will see some options have flags in capital letters, which will be replaced with the correct value for said option). Given the tree is not too shallow, the clock may not be seriously violated, and thus we have fixed a mean for the `sigma2` parameter (i.e., variation in the clock) as 0.05 using a gamma prior with $\alpha=2$ and $\beta=40$: `sigma2_gamma 2 40​`.

## 4. Generating input data for timetree inference

Lastly, we will prepare a directory called `00_inp_data` in the `main` directory with all the input files we shall use for timetree inference:

* Alignment files: `aln_12CP.phy`, `aln_12CP3CP.phy`, `aln_123CP.phy`.
* Tree files: `cytb_calib_MCMCtree.tre`, `cytb_fordisplay_calib_MCMCtree.tre`, `cytb_uncalib.tree`.
* Directory with calibration files: `calibs/`.

We will use the following code snippet for this purpose:

```sh
## Run from directory `data_processing`
# You should still be in directory `tree`,
# so we will change directories first. If you 
# are already in `data_processing`, please ignore
# the first command that changes directories!
cd ../../
mkdir ../00_inp_data
cp -R calibs/ ../00_inp_data/
cp 01_inp_data/* ../00_inp_data
```

Now, we can move onto the next step: [running `BASEML`!](../01_PAML/00_Hessian/README.md)
