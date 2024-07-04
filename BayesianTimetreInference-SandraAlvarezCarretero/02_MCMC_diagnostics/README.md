# MCMC diagnostics

Now that we have the output files from the different MCMC runs in an organised file structure, we are ready to run MCMC diagnostics! We will start by analysing the samples we collected from the prior and then, if there are no problems, we will proceed to analyse those collected when the target distribution was the posterior.

## Prior

We are going to run the R script [`MCMC_diagnostics_prior.R`](scripts/MCMC_diagnostics_prior.R) and follow the detailed step-by-step instructions detailed in the script. In a nutshell, the protocol will be the following:

1. Load the `mcmc.txt` files generated after each run.
2. Generate a convergence plot with the unfiltered chains.
3. Find whether there are major differences between the time estimates sampled across the chains for the same node sin the 97.5% and the 2.5% quantiles. If so, flag and delete said chains.
4. If some chains have not passed the filters mentioned above, create an object with the chains that have passed the filters.
5. Generate a new convergence plot with those chains that passed the filters.
6. Calculate Rhat, tail-ESS, and bulk-ESS to check whether chain convergence has been reached with the chains that have passed filters.

<details>
<summary><b>How did we generate the input calibration files in <code>00_inp_data/calibs/inp_calibs</code>?</b></summary>
<br>

<i>Unfortunately, we will not have time to go through these scripts but, when you finish the tutorial, feel free to check how to run [the in-house R script](../00_inp_data/calibs/scripts/Include_calibrations_MCMCtree.R) and the corresponding section on how to calibrate a tree in the `README.md` file under [`data_processing`](../data_processing/README.md#calibrating-the-tree-topology).

If you have run `MCMCtree` and generated output file [`node_tree.tree`](../01_timetree_inference/01_MCMCtree/00_prior/node_tree.tree), you can then run the second [in-house R script `Merge_node_labels.R`](scripts/Merge_node_labels.R), which will output the [`Calibnodes_mtcdnapri.csv` file](../00_inp_data/calibs/inp_calibs/Calibnodes_cytb.csv) that you will need for the subsequent steps of the MCMC diagnostics!</i>

</details>
<br>

If you are using your own PC, you can either open the R script [`MCMC_diagnostics_prior.R`](scripts/MCMC_diagnostics_prior.R) on RStudio and run it from there or run the R script  [`MCMC_diagnostics_prior_terminal.R`](scripts/MCMC_diagnostics_prior_terminal.R) from the Terminal **if you have installed R and all the different packages that are required to run MCMC diagnostics as specified in the [main `README.md`](../README.md#running-r-and-rstudio) via the command line**. If you are using a Docker container, all the aforementioned packages should have already been installed there, so you can run the R script [`MCMC_diagnostics_prior_terminal.R`](scripts/MCMC_diagnostics_prior_terminal.R) without problems. The command to execute the script from the Terminal needs only one argument: the absolute path to the [`02_MCMC_diagnostics/scripts`](scripts) directory (i.e., type `pwd` on a Terminal open in this location to know its absolute path). Once you know the absolute path to such directory, please do the following:

```sh
## Run from `02_MCMC_diagnostics/scripts` directory
#
# Arg1  Absolute path to directory `02_MCMC_diagnostics/scripts`
Rscript MCMC_diagnostics_prior_terminal.R <path_to_your_directory>ppgcourse2024_week1/BayesianTimetreInference-SandraAlvarezCarretero/02_MCMC_diagnostics/scripts
```

You will see that various plots and tables (and a log file with the screen output if you used a terminal) will have been generated. We will go through them once everyone is ready!

The MCMC diagnostics did not find any of the chains problematic after running our R script. Therefore, we used [our in-house bash script `Combine_MCMC.sh`](../01_timetree_inference/scripts/Combine_MCMC.sh) to concatenate all the `mcmc.txt` files for the 6 chains in a unique file as shown below:

```sh
## Run from `01_timetree_inference/01_MCMCtree`
# You should still be in directory `02_MCMC_diagnostics/scripts`,
# so we will first change to the correct directory.
# If you are already in `01_timetree_inference/01_MCMCtree`,
# please ignore the first command used to change
# directories
cd ../../01_timetree_inference/scripts
cp Combine_MCMC.sh ../01_MCMCtree/00_prior
# One argument taken: number of chains
cd ../01_MCMCtree/00_prior
## Variables needed
## arg1 --> name of directory where analyses have taken place (e.g., CLK, GBM, ILN)
## arg2 --> output dir: mcmc_files_CLK, mcmc_files_GBM, mcmc_files_ILN, etc.
## arg3 --> "`seq 1 36`", "1 2 5", etc. | depends on whether some chains were filtered out or not
## arg4 --> clock model used: ILN, GBM, CLK
## arg5 --> number of samples specified to collect in the control file to run `MCMCtree`
## arg6 --> 'Y' to generate a directory with files compatible with programs such as `Tracer` to visually
##          inspect traceplots, convergence plots, etc. 'N' otherwise
## arg7 --> if arg6 is 'Y', arg7 needs to have a name for the `mcmcf4traces_<name>` that will be
##          generated. If `arg6` is equal to 'N', then please write `N` too.
path_to_data=$( echo CLK )
num_dat=3
name_dat=( 'cytb-123CP' 'cytb-12CP' 'cytb-12CP3CP') # if you had more dataset, you would add them here!
count=-1 #  counter will start at 0 in first iteration!
for i in `seq 1 $num_dat`
do
count=$(( count + 1 ))
# Run the in-house script to generate concatenated
# `mcmc.txt` file and the individual `mcmc.txt` files
# ready to visually inspect in e.g., Tracer
./Combine_MCMC.sh $path_to_data/$i mcmc_files_${name_dat[count]}_CLK "`seq 1 6`" GBM 20000 Y ${name_dat[count]}_CLK
done
```

The script above will generate a directory called `mcmc_files_<name_dataset>_CLK` inside the `00_prior` directory, where the `mcmc.txt` with the concatenated samples will be saved. In addition, a directory called `mcmcf4traces_<namedataset>_CLK` will also be generated so that formatted MCMC files compatible with programs such as `Tracer` can be used to check for chain convergence. A template script to generate the `FigTree.tre` file with this `mcmc.txt` has been saved inside the [`dummy_ctl_files`](../01_timetree_inference/dummy_ctl_files) directory.

We will now create a dummy alignment with only 2 nucleotides to quickly run `MCMCtree` with option `print = -1`. This setting will basically (i) ignore all the settings regarding the evolutionary model and the MCMC, (ii) read the `mcmc.txt` file which path is set in option `mcmcfile`, (iii) and summarise all the samples in such file to generate a timetree. To create the dummy alignment, we will run the in-house R script [`Generate_dummy_aln.R`](../01_timetree_inference/scripts/Generate_dummy_aln.R) (if using RStudio) or [`Generate_dummy_aln_terminal.R`](../01_timetree_inference/scripts/Generate_dummy_aln_terminal.R). If you are running the script from the Terminal, it will again take only one argument: the absolute path to the [`01_timetree_inference/scripts`](../01_timetree_inference/scripts) directory. Once you know the absolute path to such directory, please do the following:

```sh
## Run from `01_timetree_inference/scripts` directory
# Now, you should be inside `01_MCMCtree/00_prior/`,
# so use the first command to change directories.
# If you are already in `01_timetree_inference/scripts`,
# please ignore the first command used to change
# directories
#
cd ../../scripts
# Arg1  Absolute path to directory `01_timetree_inference/scripts`
Rscript Generate_dummy_aln_terminal.R <path_to_your_directory>ppgcourse2024_week1/BayesianTimetreInference-SandraAlvarezCarretero/01_timetree_inference/scripts
```

Once you run this script, a new directory called `dummy_aln` will be created, which will contain the dummy alignment. Then, we are ready to run `MCMCtree` with option `print = -1`! Note that the `mcmc.txt` file will have all the samples collected by the chains that passed previous filters during MCMC diagnostics.

```sh
## Run from `scripts`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
# 
# Arg 1  First arg is the name of the calibrated tree file inside `00_inp_data`
# Arg 2  Second arg is the name that launches MCMCtree as an alias or exported to the path
./run_prior_for_tree.sh cytb_calib_MCMCtree.tree mcmctree
```

We now have our timetree inferred with all the samples collected by all the chains that passed the filters during MCMC diagnostics (when sampling from the prior)! The next step is to plot the calibration densities VS the marginal densities to verify whether there are any serious clashes that may arise because of truncation or problems with the fossil calibrations used. We will use the [in-house R script `Check_priors_margVScalib.R`](scripts/Check_priors_margVScalib.R) (when using RStudio) or script [in-house R script `Check_priors_margVScalib_terminal.R`](scripts/Check_priors_margVScalib_terminal.R) (when running the script from the Terminal) to generate these plots. If the latter, please use the command below:

```sh
## Run from `02_MCMC_diagnostics/scripts` directory
# Now, you should be inside `01_MCMCtree/scripts/`,
# so use the first command to change directories.
# If you are already in `01_timetree_inference/scripts`,
# please ignore the first command used to change
# directories
#
cd ../../02_MCMC_diagnostics/
# Arg1  Absolute path to directory `02_MCMC_diagnostics/scripts``
Rscript Check_priors_margVScalib_terminal.R <path_to_your_directory>ppgcourse2024_week1/BayesianTimetreInference-SandraAlvarezCarretero/02_MCMC_diagnostics/scripts
```

Once this script has finished, you will see that a new directory `plots/margVScalib/<name_dataset>` will have been created. Inside this directory, you will find one directory for each individual dataset with individual plots for each node. In addition, all these plots have been merged into a unique document as well (note: some plots may be too small to see for each node, hence why we have generated individual plots).

Now, once the MCMC diagnostics have finished, you can extract the final data that you can use to write a manuscript as it follows (easy way of accessing important files without having to navigate the file structure!):

```sh
## Run from `02_MCMC_diagnostics`
# You should still be in directory `02_MCMC_diagnostics/scripts`
# so we will first change directories.
# If you are already where you need to be, please
# ignore the command referring to changind
# directories below
cd  ../
mkdir sum_files_prior
cp -R ../01_timetree_inference/01_MCMCtree/00_prior/mcmc_files*CLK/*CLK*tree sum_files_prior/
cp -R ../01_timetree_inference/01_MCMCtree/00_prior/CLK/*/*/*all_mean*tsv sum_files_prior/
cp -R plots/ESS_and_chains_convergence/*prior*pdf sum_files_prior/
cp -R plots/margVScalib sum_files_prior/
```

## Posterior

Now it is time to analyse the samples we collected when running `MCMCtree` with our data!

We will run the R script [`MCMC_diagnostics_posterior.R`](scripts/MCMC_diagnostics_posterior.R) (when using RStudio) or [`MCMC_diagnostics_posterior_terminal.R`](scripts/MCMC_diagnostics_posterior_terminal.R) (when running this script from the Terminal) and follow the detailed step-by-step instructions detailed in the script, which are essentially the same ones you used when analysing the samples collected when sampling from the prior.

```sh
## Run from `02_MCMC_diagnostics/scripts` directory
# You should still be in `02_MCMC_diagnostics` directory,
# so we will need to change directories. If you are
# already in the correct directory, please ignore
# the command that changes directory below
cd scripts
#
# Arg1  Absolute path to directory `02_MCMC_diagnostics/scripts`
Rscript MCMC_diagnostics_prior_terminal.R <path_to_your_directory>ppgcourse2024_week1/BayesianTimetreInference-SandraAlvarezCarretero/02_MCMC_diagnostics/scripts
```

Given that no problems have been found with any of the chains we ran, we are ready to concatenate the parameter values sampled across the 6 independent chains we ran:

```sh
## Run from `01_timetree_inference/01_MCMCtree`
# You should still be in directory `02_MCMC_diagnostics/scripts`,
# so we will first change to the correct directory.
# If you are already in `01_timetree_inference/01_MCMCtree`,
# please ignore the first command used to change
# directories
cd ../../01_timetree_inference/scripts
cp Combine_MCMC.sh ../01_MCMCtree/01_posterior
# One argument taken: number of chains
cd ../01_MCMCtree/01_posterior
## Variables needed
## arg1 --> name of directory where analyses have taken place (e.g., CLK, GBM, ILN)
## arg2 --> output dir: mcmc_files_CLK, mcmc_files_GBM, mcmc_files_ILN, etc.
## arg3 --> "`seq 1 36`", "1 2 5", etc. | depends on whether some chains were filtered out or not
## arg4 --> clock model used: ILN, GBM, CLK
## arg5 --> number of samples specified to collect in the control file to run `MCMCtree`
## arg6 --> 'Y' to generate a directory with files compatible with programs such as `Tracer` to visually
##          inspect traceplots, convergence plots, etc. 'N' otherwise
## arg7 --> if arg6 is 'Y', arg7 needs to have a name for the `mcmcf4traces_<name>` that will be
##          generated. If `arg6` is equal to 'N', then please write `N` too.
path_to_data_GBM=GBM
path_to_data_ILN=ILN
num_dat=3
name_dat=( 'cytb-123CP' 'cytb-12CP' 'cytb-12CP3CP') # if you had more dataset, you would add them here!
count=-1 #  counter will start at 0 in first iteration!
for i in `seq 1 $num_dat`
do
count=$(( count + 1 ))
./Combine_MCMC.sh $path_to_data_GBM/$i mcmc_files_${name_dat[count]}_GBM "`seq 1 6`" GBM 20000 Y ${name_dat[count]}_GBM
./Combine_MCMC.sh $path_to_data_ILN/$i mcmc_files_${name_dat[count]}_ILN "`seq 1 6`" ILN 20000 Y ${name_dat[count]}_ILN
done
```

Once the tasks above have finished, directories called `mcmc_files_cytb*[GBM|ILN]` and `mcmcf4traces_cytb*` will be created inside `01_posterior/`. To map the mean time estimates with the filtered chains, we need to copy a control file, the calibrated Newick tree, and the dummy alignment we previously generated when analysing the results when sampling from the posterior:

```sh
## Run from `scripts`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
# 
# Arg 1  First arg is the name of the calibrated tree file inside `00_inp_data`
# Arg 2  Second arg is the name that launches MCMCtree as an alias or exported to the path
./run_post_for_tree.sh cytb_calib_MCMCtree.tree mcmctree
```

Once you have your final timetrees estimated under the two different relaxed-clock models (yay!), we can run our in-house R script ([`Check_priors_VS_posteriors.R`](scripts/Check_priors_VS_posteriors.R) for RStudio or [`Check_priors_VS_posteriors_terminal.R`](scripts/Check_priors_VS_posteriors_terminal.R) when using a Terminal) to compare various distributions: marginal densities, calibration densities, and posterior time densities! These plots can help assess how informative the data are and check whether there are serious differences between the marginal densities and the posterior time densities.

Lastly, you can extract the final data that we used to write our manuscript as it follows:

```sh
## Run from `02_MCMC_diagnostics`
# You should still be in directory `scripts`,
# so we will first change to the correct directory.
# If you are already in `02_MCMC_diagnostics`,
# please ignore the first command used to change
# directories
cd ../
mkdir sum_files_post
cp -R ../01_timetree_inference/01_MCMCtree/01_posterior/mcmc_files_*/FigTree*tree sum_files_post/
cp -R ../01_timetree_inference/01_MCMCtree/01_posterior/*/*/*/*all_mean*tsv sum_files_post/
cp -R plots/priorVSpost*pdf sum_files_post/
cp -R plots/ESS_and_chains_convergence/*post*pdf sum_files_post/
```

And... This is the end of the tutorial! We will discuss our results and see how we can use `Tracer` and `TreeViewer` to visualise our output files saved in directories `sum_files_[post|prior]`.

Hope you have enjoyed this journey on timetree inference :)

----
