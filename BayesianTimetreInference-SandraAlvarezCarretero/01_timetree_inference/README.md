# Timetree inference with `PAML` programs

## 1. Running `BASEML`

We will first prepare the input files required to run `BASEML`, which you can execute by running `MCMCtree` with option `usedata = 3`. Note that, once the input files are ready, we will run `BASEML` three times as there are three different types of alignment blocks:

* **All codon positions**: alignment block with one gene alignment with all codon positions. This alignment block is part of input sequence file [`aln_123CP.phy`](../00_inp_data/aln_123CP.phy).
* **Only first and second codon positions**: one alignment block with only the first and the second codon positions. This alignment block is part of input sequence files [`aln_12CP.phy`](../00_inp_data/aln_12CP.phy) and [`aln_12CP3CP.phy`](../00_inp_data/aln_12CP3CP.phy).
* **Only third codon position**: one alignment block with only the third codon positions. This alignment block is part of input sequence file [`aln_12CP3CP.phy`](../00_inp_data/aln_12CP3CP.phy).

We will use the code below to generate the file structure to run `BASEML` with one directory per alignment block:

```sh
## Run from directory `scripts`
# Please use your terminal to navigate to 
# this directory, then copy the commands below
# on your terminal
chmod 775 *sh
./prepare_baseml_struct.sh
```

After running the command above, a new directory called `00_BASEML` will have been created with subdirectories `1`, `2`, and `3`. Inside each subdirectory, you shall find three modified copies of the [`template_paml.ctl` file](01_timetree_inference/template_paml.ctl) that can read each alignment block. Now, we will use the code snippet below to run `BASEML` in directories `00_BASEML/1`, `00_BASEML/2`, and `00_BASEML/3`:

```sh
## Run from `00_BASEML`
# You should still be in directory `scripts`,
# so change directories until you are `00_BASEML`.
# If you are already there, please ignore the
# first set of commands to change directories
cd ../00_BASEML
home_dir=$( pwd )
for i in `seq 1 3`
do
cd $home_dir/$i
printf "[[ Analysing alignment block "$i" ]]\n"
# Run `MCMCtree` to prepare input files
# for `BASEML` (i.e., you will not run
# timetree inference now, `MCMCtree` is
# just in charge of creating the input
# files for `BASEML`!)
mcmctree *ctl > log_screen.txt &
pid=$!
if [[ $i -eq 1 ]]
then
echo Start job for alignment block in directory $i with PID process $pid
echo Start job for alignment block in directory $i with PID process $pid > $home_dir/log_step1_PIDs.txt
else
echo Start job for alignment block in directory $i with PID process $pid
echo Start job for alignment block in directory $i with PID process $pid >> $home_dir/log_step1_PIDs.txt
fi
done
cd $home_dir
# You may need to press the return key twice!
```

Note that, when we ran the commands above, we were not interested in running `BASEML` or `MCMCtree` until "the end". We just wanted to execute `MCMCtree` with option `usedata = 3` so that this program can generate the `tmp000*` files that `BASEML` will then need as input files to estimate the branch lengths, the gradient, and the Hessian. We carry out this analysis in two steps so that we can replace option `method = 0` with `method = 1` in the `tmp0001.ctl` file that will be output with the commands above. As explained in the [`PAML` documentation](https://github.com/abacus-gene/paml/blob/master/doc/pamlDOC.pdf) (at the time of writing, page 56), the iteration algorithm enabled when setting `method = 1` is much more efficient with large datasets than the algorithm enabled when setting `method = 0`. While this is not a very large dataset, it is good practice to divide these steps into two so that you can always check the `BASEML` settings in the automatically created `tmp0001.ctl` files!

Once we see the `tmp0001.ctl` file generated, we can therefore kill the job by pressing `ctrl+C`. In this case, the dataset is so small that you will not even have time to press `ctrl+C`! When analysing large datasets, you may be stuck for a while after you see the following lines, which is when you can kill the job as the `tmp*` files will appear:

```text
161 site patterns read, 1140 sites
Counting frequencies..

      336 bytes for distance 
    36064 bytes for conP
     6440 bytes for fhK
  8000000 bytes for space
```

After you have killed the job, you can run the following commands to make sure that the correct settings to run `BASEML` are enabled:

```sh
## Run from the `00_BASEML`.
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
sed -i 's/method\ \=\ 0/method\ \=\ 1/' */tmp0001.ctl
grep 'method = 1' */tmp0001.ctl | wc -l # You should get as many as datasets you have: 3
grep 'alpha' */tmp0001.ctl   # You should see `fix_alpha = 0` and `alpha = 0.5`
grep 'ncatG' */tmp0001.ctl   # You should see `ncatG = 5`
grep 'model' */tmp0001.ctl   # You should see `model = 4` (i.e., HKY model)
```

Now, we can run `BASEML`!

```sh
## Run from `00_BASEML`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
home_dir=$( pwd )
for i in `seq 1 3`
do
cd $home_dir/$i
mkdir $home_dir/$i/baseml
cp $home_dir/$i/tmp0001* $home_dir/$i/baseml
cd  $home_dir/$i/baseml
rm  tmp0001.out
baseml *ctl > $home_dir/$i/baseml/log.txt &
pid=$!
if [[ $i -eq 1 ]]
then
echo Start BASEML for alignment block in directory $i with PID process $pid
echo Start BASEML for alignment block in directory $i with PID process $pid > $home_dir/log_step2_PIDs.txt
else
echo Start BASEML for alignment block in directory $i with PID process $pid
echo Start BASEML for alignment block in directory $i with PID process $pid >> $home_dir/log_step2_PIDs.txt
fi
done
cd $home_dir
# You may need to press the return key twice!
```

<details>
<summary><b>TIP FOR ANALYSES WITH LARGE DATASETS</b></summary>
<br>

<i>If you have a large dataset, you may want to use a job array to run the commands above: one task for each alignment block, which can take from hours to days depending on the site patterns of your alignment! You can [check the pipelines that I provide as part of my tutorial for reproducible timetree inference](https://github.com/sabifo4/Tutorial_MCMCtree/tree/main/01_PAML/00_BASEML/scripts) if you need some examples!</i>

</details>
<br>

The branch lengths, the gradient, and the Hessian will be saved in output file `rst2` (one for each alignment block). Given that we have three sequence files, we need to generate the so-called `in.BV` for each of them:

* `aln_123CP.phy`: this sequence file has one alignment block with all codon positions. The `rst2` file that was output in directory `00_BASEML/1/` is the one that we will use as `in.BV`.
* `aln_12CP.phy`: this sequence file has one alignment block with the first and the second codon positions. The `rst2` file that was output in directory `00_BASEML/2/` is the one that we will use as `in.BV`.
* `aln_12CP3CP.phy`: this sequence file has two alignment blocks: one with the first and the second codon positions and another with the third codon positions. We will need to generate an `in.BV` file with the `rst2` file that was output in directory `00_BASEML/2/` first (i.e., same order as in the input sequence file) and then append the `rst2` file output in directory `00_BASEML/3`.

We can generate our `in.BV` files by using the code snippet below:

```sh
## Run from `00_BASEML`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
cat 1/baseml/rst2 > in_123CP.BV
cat 2/baseml/rst2 > in_12CP.BV
cat 2/baseml/rst2 > in_12CP3CP.BV
printf "\n" >> in_12CP3CP.BV
cat 3/baseml/rst2 >> in_12CP3CP.BV
```

We now have everything we need to run `MCMCtree`!

## 2. Running `MCMCtree`

We are going to run `MCMCtree` when sampling from the prior (i.e., no data are used, useful to check whether there are problems between the calibration densities specified by the user and the corresponding marginal densities inferred by the program) and the posterior (i.e., when our data are used!).

We will run 6 chains when sampling from the prior and 6 chains when sampling from the posterior:

```sh
## Run from directory `scripts`
# You should still be in directory `00_BASEML`,
# so we will change directories to be inside
# `scripts`. If you are already in this directory,
# please do not run the first command below to
# change directories
cd ../scripts
# This script has two arguments:
#
# Arg1: number of chains when samplin from the prior
# Arg2: number of chain when sampling from the posterior
./prepare_mcmctree_struct.sh 6 6
```

We can check whether our paths have been properly exported!

```sh
## Run from directory `scripts`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
grep 'seqfile' ../01_MCMCtree/*/*/*/*/*ctl
```

Now, we can run `MCMCtree`! You can either run it on your PC or decide whether you want to prepare a job array to run these analyses on a cluster (we will not discuss the latter in this quick start tutorial, but feel free to look at the job arrays and other pipelines we use throughout the [tutorial on reproducible timetree inference](../01_timetree_inference/01_MCMCtree/scripts/)):

```sh
## Run from `01_MCMCtree`
# You should still be in directory `scripts`,
# so we will change directories to be inside
# `scripts`. If you are already in this directory,
# please do not run the first command below to
# change directories
cd ../01_MCMCtree
home_dir=$( pwd )
for j in `seq 1 3`
do
for i in `seq 1 6`
do
cd $home_dir/00_prior/CLK/$j/$i
printf "\n~> Running MCMCtree for dataset "$j" | Chain "$i" | prior ]]\n"
# Run `MCMCtree` while you see the screen output but
# you also save it in a file called `log_mcmc$i"_prior.txt"`
# You will run this analysis when sampling from the prior,
# the posterior under GBM, and the posterior under ILN
mcmctree *ctl &> log_dat$j"_mcmc"$i"_prior.txt" &
pid=$!
echo Start MCMCtree for dataset $j and chain $i when sampling from the prior - PID is $pid >> $home_dir/log_prior_PIDs.txt
printf "\n~> Running MCMCtree for dataset "$j" | Chain "$i" | posterior ILN\n"
cd $home_dir/01_posterior/ILN/$j/$i
mcmctree *ctl &> log_dat$j"_mcmc"$i"_postILN.txt" &
pid=$!
echo Start MCMCtree for dataset $j and chain $i when sampling from posterior ILN - PID is $pid >> $home_dir/log_postILN_PIDs.txt
printf "\n~> Running MCMCtree for dataset "$j" | Chain "$i" | posterior GBM\n"
cd $home_dir/01_posterior/GBM/$j/$i
mcmctree *ctl &> log_dat$j"_mcmc"$i"_postGBM.txt" &
pid=$!
echo Start MCMCtree for dataset $j and chain $i when sampling from posterior GBM - PID is $pid >> $home_dir/log_postGBM_PIDs.txt
done
done
cd $home_dir
# To check when analyses are finished, you can keep pressing the return key!
```

We can now create a file that will be handy for subsequent steps: node numbers as given by `MCMCtree`. Only one tree is enough as we have the same tree topology!

```sh
## Run from `01_MCMCtree`
# You should still be in this directory 
# but, if not, please change directories until
# you are there. Then, run the following
# commands.
grep 'Species tree for FigTree' -A1 00_prior/CLK/1/1/out.txt | sed -n '2,2p' > 00_prior/node_tree.tree
```

> [NOTE!]
> When analysing your own datasets, you should always first run `MCMCtree` when sampling from the prior, proceed to [carry out MCMC diagnostics as explained below](./README.md#prior), and make sure that there are no problems between the calibration densities you specified and the marginal densities `MCMCtree` inferred. If you observed serious discrepancies, you would need to go back to your calibrations and check whether you made a mistake or you need to adjust them until the marginal densities really represent your belief about the fossil record. Then, once everything looks alright, you can run `MCMCtree` when sampling from the posterior, and then [run the corresponding MCMC diagnostics as explained below](./README.md#posterior). Nevertheless, we are running `MCMCtree` both when sampling from the prior and the posterior so that we can have the output files ready for both MCMC diagnostics while (hopefully!) completing this tutorial on time for this session :) You will see that this workflow (i.e., `prior --> checks --> prior again if checks failed --> check again --> posterior if everything is fine`) is the one you shall follow when running [my tutorial on reproducible timetree inference](https://github.com/sabifo4/Tutorial_MCMCtree/tree/main/01_PAML/01_MCMCtree).
