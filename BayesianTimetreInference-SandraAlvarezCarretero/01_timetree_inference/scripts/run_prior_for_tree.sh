#!/bin/bash

home_dir=$( pwd ) # This will be scripts directory
name_tree=$1      # First arg is the name of the calibrated tree file inside `00_inp_data`
mcmcrun=$2        # Second arg is the name that launches MCMCtree as an alias or exported to the path

# Change to `00_prior`
cd ../01_MCMCtree/00_prior
home_dir=$( pwd )
echo $home_dir

# Get `mcmc_files_*` names
name_mcmcd=`ls mcmc_files* -d`

# Specify counters
# Run loop
for i in $name_mcmcd
do
count=$(( count + 1 ))
printf "\n[[ Analysing dataset "$i" ]]\n\n"
base_dir=$( pwd )
cd ../../dummy_ctl_files
# Get path to directory where the ctl file is
ctl_dir=$( pwd )
cd ../../00_inp_data/
# Get path to directory where the tree file is
# and file name
tt_dir=$( pwd )
name_tt=$name_tree
# Go to directory with dummy sequence file,
# get directory name and file name
cd $ctl_dir
cd ../dummy_aln
aln_dir=$( pwd )
name_aln=`ls *aln`
cd $base_dir
# Go to directory where the concatenated
# `mcmc.txt` file is and start preparing
# the directory to run `MCMCtree` with
# option `print = -1`
cd $i
printf "[[ Generating tree file for concatenated \"mcmc.txt\"  ... ... ]]\n\n"
cp $ctl_dir/*ctl .
name_mcmc=`ls *mcmc.txt`
sed_aln=$( echo $aln_dir"/"$name_aln | sed 's/\//\\\//g' | sed 's/_/\\_/g' |  sed 's/\./\\\./g' )
sed_tt=$( echo $tt_dir"/"$name_tt | sed 's/\//\\\//g' | sed 's/_/\\_/g' |  sed 's/\./\\\./g' )
sed -i 's/MCMC/'${name_mcmc}'/' *ctl
sed -i -e 's/ALN/'${sed_aln}'/' *ctl
sed -i 's/TREE/'${sed_tt}'/' *ctl
# Run now `MCMCtree` after having modified
# the global vars according to the path to
# these files. Then, rename the output tree
# file so we can easily identify later which
# tree belongs to which dataset easier
printf "[[ Running MCMCtree with option \"print = -1\" ]]\n\n"
$mcmcrun *ctl
printf "\n\n[[ Generating tree file with all the collected samples ]]\n"
mv FigTree.tre FigTree_$i"_CLK_95HPD.tree"
printf "[[ Saving output tree file as FigTree_"$i"_CLK_95HPD.tree ]]\n\n"
cd $base_dir
done

# Return to base_dir
cd $base_dir