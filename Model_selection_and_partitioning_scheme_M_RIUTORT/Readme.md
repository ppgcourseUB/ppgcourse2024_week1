# EVOLUTIONARY MODELS AND PARTITION SCHEME SELECTION

Instructor: Marta Riutort

Software: 

- PartitionFinder scripts are in the folder software/partitionfinder-2.1.1/ (it is also available at http://www.robertlanfear.com/partitionfinder/)

> **You must activate the environment `partitionFinder` before runing the scripts of this software**. To do this, type directly in the terminal:` conda activate partitionFinder`


You can find additional information about PartitionFinder in its web page (see above). There are a Tutorial, a google group and FAQ links. But it is specially important that you download and read the manual (http://www.robertlanfear.com/partitionfinder/assets/Manual_v2.1.x.pdf). Reading the manual of the programs does not only teach you how to use them. You will find information on all the options the program offers, how to use them and information on why to use them. So, it will help you take the most advantage from using the program and from your data.

## Data files

As in the other hands-on sessions, you can clone the folder with all instructions and datafiles for this practice in your user working directory (i.e., the working directory when your run a container):

`ghget https://github.com/ppgcourseUB/ppgcourse2024_week1/tree/main/Model_selection_and_partitioning_scheme_M_RIUTORT`

`DATA` folder contents:

**bears_phylo.phy**: the aligned dataset including 3 nuclear protein coding genes (CHRNA1, FES, IRBP, MC4R, RNASE1), 4 mitochondrial protein coding genes (cox1, cytb, nad1 and nad5) and two mitochondrial ribosomal genes (12S and 16S) with a total length of 11573bp.

**partition_finder.cfg**:  we will modify the example given with the program to specify the options for our analysis. 
 

|OTUs included                         |
| ------------------------------------ |
|Ailuropoda_melanoleuca                |
|Arctodus_simus                        |
|Arctotherium_sp                       |
Helarctos_malayanus
Melursus_ursinus
Tremarctos_ornatus
Ursus americanus
Ursus_arctos
Ursus_maritimus
Ursus_spelaeus
Ursus_thibetanus
Ursus_thibetanus_mupinensis
Ursus_thibetanus_formosanus
Ursus_thibetanus_ussuricus
Ursus_thibetanus_thibetanus


## Objetive

Learn how to use PartitionFinder to evaluate the best partitioning scheme for our dataset and select the best model for each partition. 

## Progress 

The program requires the dataset to be in *phylip* format (the file you will use during the practice is already in the correct format). 

We will perform two analyses varying some of the options in the program, we will first run two fast analyses and then set the third (that takes a little longer to run), while the third analysis is running, we will comment the results. In all cases we will use a extreme scheme dividing all the protein coding genes by codons plus the two ribosomal genes (29 putative partitions in total).

### Files 

Files are in the directory DATA/input_files

### Prepare command file

The file *partition_finder.cfg* includes the options we select to run the PartitionFinder program. You can edit the file with `nano` to make the modifications.

1. Modifications for the first run:

COMMAND 1: 

```
## ALIGNMENT FILE ##
alignment = test.phy;
```

This command indicates to the program the name of the file with the data. We must change it to the name of our data set:

```
## ALIGNMENT FILE ##
alignment = bears_com.phy
```

COMMAND 2:

In this command we tell the program whether we want it to calculate branch lengths linked or unlinked for each subset of partitions. Only some inference programs support unlinked (MrBayes, RAxML, BEAST among them), this option requieres more paramters since each subset will have its own branchlengths (see the manual). We will leave it with the linked option

```
## BRANCHLENGTHS: linked | unlinked ##
branchlengths = linked;

```

COMMAND 3:

In this command we set the models we want to test, the more you include the slowest the program will become. You can select a list of models if you prefer, or (for some inference programs) you can select the program you are going to use for the inference of the tree and in this case PartitionFinder will only test the models that that program includes. In the case of RAxML it has to be set in the command line (see below) and then setting “all” in this command will only test the models RAxML includes. We will leave all at this step. 

```
## MODELS OF EVOLUTION: all | allx | mrbayes | beast | gamma | gammai | <list> ##
##              for PartitionFinderProtein: all_protein | <list> ##
models = all;
```

COMMAND 4:

We will leave the option at BIC. 

```
# MODEL SELECCTION: AIC | AICc | BIC #
model_selection = BIC;
```

COMNAND 5:

```
## DATA BLOCKS: see manual for how to define ##
[data_blocks]
Gene1_pos1 = 1-789\3;
Gene1_pos2 = 2-789\3;
Gene1_pos3 = 3-789\3;
Gene2_pos1 = 790-1449\3;
Gene2_pos2 = 791-1449\3;
Gene2_pos3 = 792-1449\3;
Gene3_pos1 = 1450-2208\3;
Gene3_pos2 = 1451-2208\3;
Gene3_pos3 = 1452-2208\3;
```

This is a very important command, here you define the data blocks you want to test (so the partitions!). We will set a subset for each codon position in the protein coding genes. Copy the following for our data set: 

```
## DATA BLOCKS: see manual for how to define ##
[data_blocks]
CHRNA1_1= 1-362\3;
CHRNA1_2 = 2-362\3;
CHRNA1_3 = 3-362\3;
FES_1 = 363-831\3;
FES_2 = 364-831\3;
FES_3 = 365-831\3;
IRBP_1 = 832-2111\3;
IRBP_2 = 833-2111\3;
IRBP_3 = 834-2111\3;
MC4R_1 = 2112-3110\3;
MC4R_2 = 2113-3110\3;
MC4R_3 = 2114-3110\3;
RNASE1_1 = 3111-3530\3;
RNASE1_2 = 3112-3530\3;
RNASE1_3 = 3113-3530\3;
mt12S = 3531-4517;
mt16S = 4518-6107;
mtCOX1_1 = 6108-7652\3;
mtCOX1_2 = 6109-7652\3;
mtCOX1_3 = 6110-7652\3;
mtCYTB_1 = 7653-8787\3;
mtCYTB_2 = 7654-8787\3;
mtCYTB_3 = 7655-8787\3;
mtNAD1_1 = 8788-9743\3;
mtNAD1_2 = 8789-9743\3;
mtNAD1_3 = 8790-9743\3;
mtNAD5_1 = 9744-11573\3;
mtNAD5_2 = 9745-11573\3;
mtNAD5_3 = 9746-11573\3;
```

COMMAND 6:

```
## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
[schemes]
search = all;
```

With this command we set the searching strategy. A rough guide is to use ‘all’ for very small datasets (so never for phylogenomic studies), ‘greedy’ for datasets of ~10 loci, and ‘rcluster’ for datasets of 100’s of loci (however, rcluster is only available when you use the command line –raxml, see below, so only RAxML models will be tested). We are going to use the –raxml command line and will try two options ‘greedy’ and ‘rcluster’

In the first run use greedy:

```
## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
[schemes]
search = greedy;
```

Once done the changes, you can run the first analysis.


### Run the first analysis

Execture the script *partition_finder.run* from the folder of this practice.

Here you have the content of this script:

```
#!/bin/bash
          
# setting some variables:
FOLDER="DATA/input_files"

# running PartitionFinder
./software/partitionfinder-2.1.1/PartitionFinder.py $FOLDER --raxml -p 8
```

> We are giving the ‘–-raxml’ command so that only the models of RAxML will be tested, this is going to do the run faster and you will be able to see the results immediately. We will also run another analysis wihtout the –raxml option, with beast at models command and greedy at the Schemes commad (it will take longer to run) to compare the results.

If all is ok, the program will generate within your user directory a folder named “analysis”. 
Within this folder you will find a textfile called “best_scheme.txt”; here you will find the results and the partition scheme and models to apply in RAxML format so that you can directly use it in that program to infer your tree.

> **IMPORTANT NOTE:** ONCE FINISHED CHANGE THE NAME OF THE OUTPUT DIRECTORY SO THAT WHEN RUNNING THE SECOND ANALYSIS YOU DO NOT OVERWRITE THE FIRST ANALYSIS RESULTS 

In a second run substitute greedy by rcluster in COMMAND 6 in the file partition_finder.cfg
In the cloud you can edit the file partition_finder.cfg with `nano` to make the modification (for using nano in the cloud first load the nano module):


```
## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
[schemes]
search = rcluster;
```

### Run the second analysis

Execture the script *partition_finder.run* from the folder of this practice.

> **IMPORTANT NOTE**: ONCE FINISHED THE SECOND ANALYSIS **CHANGE THE NAME** OF THE OUTPUT DIRECTORY **SO THAT WHEN RUNNING THE THIRD ANALYSIS YOU DO NOT OVERWRITE THE SECOND ANALYSIS RESULTS**


### Run the third analysis

We must edit the partition_finder.cfg file again. Open the file with nano and do the following changes:

COMMAND 3:

```
## MODELS OF EVOLUTION: all | allx | mrbayes | beast | gamma | gammai | <list> ##
##              for PartitionFinderProtein: all_protein | <list> ##
models = all;
```

Since you will use `BEAST` in some of the next classes, we will select "beast" so that `PartitionFinder` finds the best model amongst those that are found in the `BEAST` software. We will change to beast. 

```
## MODELS OF EVOLUTION: all | allx | mrbayes | beast | gamma | gammai | <list> ##
##              for PartitionFinderProtein: all_protein | <list> ##
models = beast;
```

COMMAND 6:

Make sure command 6 is set to greedy.

```
## SCHEMES, search: all | greedy | rcluster | hcluster | user ##
[schemes]
search = greedy;
```

Now, you can execute the file *partition_finder2.run*:

```
#!/bin/bash           

# setting some variables:
FOLDER="DATA/input_files"

# running PartitionFinder
./software/partitionfinder-2.1.1/PartitionFinder.py $FOLDER -p 8
```

> Notice that we are not giving the ‘–-raxml’ command so now all models present in `BEAST` will be tested, which will take longer than in our previous analyses because `RAxML` only offers "GTR", "GTRGAMMA" and "GTRGAMMA+I", while `BEAST` has a longer list of possibilities.

While this third analysis is running, we are going to have a look to the results of the two previous analyses.

### Results

Write in the following the list of partition schemes selected in each analysis and models assigned to them:


--raxml command line, all model option

1. Greedy search

|Partitions|Evolutionary models|
| -------- | ----------------- |
|   .      |                   |
|   ..     |                   |   
|   ...    |                   |



2. Rcluster search

|Partitions|Evolutionary models|
| -------- | ----------------- |
|   .      |                   |
|   ..     |                   |   
|   ...    |                   |



3. Non --raxml command line, beast model option

|Partitions|Evolutionary models|
| -------- | ----------------- |
|   .      |                   |
|   ..     |                   |   
|   ...    |                   |
















