#!/bin/bash

home_dir=$( pwd ) # This will be scripts directory
nch_prior=$1     # First arg is number of chains when sampling from the prior
nch_post=$2      # Second arg is number of chains when sampling from the posterior

# Move to working dir
cd ../
printf "\nGenerating file structure to run MCMCtree...\n"

for j in `seq 1 3`
do

# Get values for file names
if [[ $j -eq 1 ]]
then
CPs=$( echo 123CP )
parts=$( echo 1 )
elif [[ $j -eq 2 ]]
then
CPs=$( echo 12CP )
parts=$( echo 1 )
elif [[ $j -eq 3 ]]
then
CPs=$( echo 12CP3CP )
parts=$( echo 2 )
fi

printf "\n[[ Structure to analyse sequence file "$j" | aln_"$CPs".phy ]]\n"

for i in `seq 1 $nch_prior`
do
# Create file structure for the analyses we will carry out
mkdir -p 01_MCMCtree/00_prior/CLK/$j/$i
printf "~> Copy files for chain "$i" and sequence file "$j" | PRIOR\n"

# Copy files for prior
cp template_paml.ctl 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
# Modify the path to the input sequence file:
# the name of the partitioned alignment was there,
# but the path has changed. We are using a relative
# path!
sed -i 's/ALN/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\/aln_'${CPs}'\.phy/' 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above, but now modify the path to the
# input tree file
sed -i 's/treefile\ \=\ /treefile\ \=\ \.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\//' 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
# Modify option `usedata` so that `MCMCtree` samples
# from the prior (i.e., no data)
sed -i 's/usedata..*/usedata\ \=\ 0/' 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
# The analysis will always run faster when no `sigma_2` values are
# sampled, so we specify `clock = 1`. If you specified a
# relaxed-clock model, you would get estimates for the rate
# variation in the `mcmc.txt` file apart from `mu` values
# (one for each alignment block if there is a partitioned
# alignment)
sed -i 's/clock..*/clock\ \=\ 1/' 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
# Modify number of partitions
sed -i 's/NUMPART/'${parts}'/' 01_MCMCtree/00_prior/CLK/$j/$i/mcmctree_$j"_r"$i.ctl
done 

for i in `seq 1 $nch_post`
do
# Create file structure for the analyses we will carry out
mkdir -p 01_MCMCtree/01_posterior/{ILN,GBM}/$j/$i
printf "~> Copy files for chain "$i" and sequence file "$j" | POSTERIOR\n"

# Copy files for posterior (ILN)
cp template_paml.ctl 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above: modify the path to where the input sequence
# file is
sed -i 's/ALN/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\/aln_'${CPs}'\.phy/' 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above: modify the path to where the input tree
# file is
sed -i 's/treefile\ \=\ /treefile\ \=\ \.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\//' 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl
# Specify `usedata = 2` and the path to the `in.BV` that
# we have just generated, which has the branch lengths,
# gradient, and Hessian estimated by `BASEML` that 
# `MCMCtree` will use to approximate the likelihood
# calculation during the MCMC
sed -i 's/usedata..*/usedata\ \=\ 2 \.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_BASEML\/in_'${CPs}'\.BV/' 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl
# Set `clock = 2` so that the independent-rates
# log-normal model is enabled
sed -i 's/clock..*/clock\ \=\ 2/' 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl
# Modify number of partitions
sed -i 's/NUMPART/'${parts}'/' 01_MCMCtree/01_posterior/ILN/$j/$i/mcmctree_$j"_r"$i.ctl

# Copy files for posterior (GBM)
cp template_paml.ctl 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above: modify the path to where the input sequence
# file is
sed -i 's/ALN/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\//' 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above: modify the path to where the input tree
# file is
sed -i 's/treefile\ \=\ /treefile\ \=\ \.\.\/\.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_inp\_data\//' 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
# Same as above, set `usedata = 2`
sed -i 's/usedata..*/usedata\ \=\ 2 \.\.\/\.\.\/\.\.\/\.\.\/\.\.\/00\_BASEML\/in_'${CPs}'\.BV/' 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
# Set `clock = 3` so that the geometric Brownian 
# motion model (autocorrelated rates) is enabled
sed -i 's/clock..*/clock\ \=\ 3/' 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
# Modify number of partitions
sed -i 's/NUMPART/'${parts}'/' 01_MCMCtree/01_posterior/GBM/$j/$i/mcmctree_$j"_r"$i.ctl
done

done

printf "\nFile structure saved under "$home_dir"/01_MCMCtree\n\n"
