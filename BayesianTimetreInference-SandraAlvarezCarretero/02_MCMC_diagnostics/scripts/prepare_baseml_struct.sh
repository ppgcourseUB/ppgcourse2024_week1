#!/bin/bash

home_dir=$( pwd ) # This will be scripts directory

# Move to working dir
cd ../
printf "\nGenerating file structure to run BASEML...\n"

# Start tasks
for i in `seq 1 3`
do
mkdir -p 00_BASEML/$i
if [[ $i -eq 1 ]]
then
CPs=$( echo 123CP )
elif [[ $i -eq 2 ]]
then
CPs=$( echo 12CP )
elif [[ $i -eq 3 ]]
then
CPs=$( echo 12CP3CP )
fi
cp template_paml.ctl 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
# Modify the path to the input sequence file,
# the alignment blocks
sed -i 's/ALN/\.\.\/\.\.\/.\.\/00\_inp\_data\/aln_'${CPs}'\.phy/' 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
# Modify the path to the input tree file
sed -i 's/treefile\ \=\ /treefile\ \=\ \.\.\/\.\.\/.\.\/00\_inp\_data\//' 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
# Specify `usedata = 3`, which will enable the settings
# for generating the `in.BV` file for approximating
# likelihood calculation
sed -i 's/TYPEINF/3/' 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
# Modify option `ndata` to make sure you will have
# only one alignment block (i.e., remember that you are
# creating one control file per alignment block within 
# this `for` loop!)
sed -i 's/NUMPART/1/' 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
# Option `clock` will be ignored, so we can put any 
# value (e.g., clock = 1 )
sed -i 's/CLK/1/' 00_BASEML/$i/mcmctree_baseml_$CPs.ctl
done

printf "\nFile structure saved under "$home_dir"/00_BASEML\n\n"