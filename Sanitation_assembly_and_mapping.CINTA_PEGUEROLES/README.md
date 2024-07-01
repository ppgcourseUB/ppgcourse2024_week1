# From raw reads to processed alignments

Instructor: **Cinta Pegueroles Queralt**

The goal of this practical session is to learn how to obtain a <em>de novo</em> transcriptome from RNAseq data. The practical is organized in four main steps:

1. **Sanitation**: pre-processing RNAseq data  
2. **<em>de novo</em> assembly**: in the absence of a reference genome
3. **QC**: assessing the quality of de novo transcriptome
4. **Post-processing analyses**

Remember that you can download the folder of this hands-on session within the container using `ghget`:

```
ghget https://github.com/ppgcourseUB/ppgcourse2024_week1/tree/main/Sanitation_assembly_and_mapping.CINTA_PEGUEROLES
cd Sanitation_assembly_and_mapping.CINTA_PEGUEROLES
```

> **You must activate the environment `partitionFinder` before runing the scripts of this software**. To do this, type directly in the terminal:` conda activate trinity`


### 0. Downloading data:
Due to time and computer resources we will work with a test data set from [TRINITY GITHUB][https://github.com/trinityrnaseq/trinityrnaseq/tree/devel/sample_data/test_Trinity_Assembly]

```
mkdir 0data
cd 0data
wget https://github.com/trinityrnaseq/trinityrnaseq/raw/devel/sample_data/test_Trinity_Assembly/reads.left.fq.gz
wget https://github.com/trinityrnaseq/trinityrnaseq/raw/devel/sample_data/test_Trinity_Assembly/reads.right.fq.gz
cd ..
```

### 1.1. Quality control of RNAseq data
Now we will perform the quality control (QC) of the RNAseq data using the software `FastQC`. First of all, we will create a folder for the QC output files

```
mkdir 1QC
```

First we will create/edit a bash script to run `FastQC` software in the cluster (*fastqc.run*):

```
#!/bin/bash

# jobs to launch
fastqc -t 8 ./0data/reads.left.fq.gz ./0data/reads.right.fq.gz -o ./1QC
```

To launch `FastQC` script in the cluster write on the terminal:
```
bash scripts/fastQC.run
```

To check the results you need to have the files on the local folded that you are sharing with the container. 
```
# if you named the shared folder /data:
cp -r path_to_the_results /data
```

### 1.2. Trimming sequences

If we detect a drop in the quality of the sequences and/or the presence of adapters we need to trim our sequences. We will do it by using the `Trimmomatic` software.

First, we will create a folder for the trimmed sequences:

```
mkdir 2trimmed_data
```

Then we will create/edit a bash script to run Trimmomatic software in the cluster (*trimseq.run*).

```
#!/bin/bash

# jobs to launch
trimmomatic PE -threads 8 ./0data/reads.left.fq.gz ./0data/reads.right.fq.gz ./2trimmed_data/reads_1.P.fq.gz ./2trimmed_data/reads_1.U.fq.gz ./2trimmed_data/reads_2.P.fq.gz ./2trimmed_data/reads_2.U.fq.gz ILLUMINACLIP:./TruSeq3-PE.fa:2:30:1 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
```

To launch the Trimmomatic script in the cluster write on the terminal:
```
bash scripts/trimSeq.run
```

### 1.3. Quality control of the trimmed sequences
Now we will perform the quality control (QC) of the trimmed sequences using again the software `FastQC`. First of all, we will create a folder for the QC output files

```
mkdir 3QC_trimmed
```
Since now we have 4 files to check (2 paired, 2 unpaired) we will use a loop to avoid repeating commands. We will create/edit a bash script to run `FastQC` software in loop over all trimmed sequences (*fastqc_loop.run*).

```
#!/bin/bash

# jobs to launch
for file in ./2trimmed_data/*fq.gz;
        do
               fastqc -t 5 $file -o ./3QC_trimmed
        done
```

To launch fastQC_loop.sh script in the cluster write on the terminal:
```
bash scripts/fastQC_loop.run
```

To check the results you need to have the files on the local folded that you are sharing with the container. 
```
# if you named the shared folder /data:
cp -r path_to_the_results /data
```

### 2. <em>De novo</em> transcriptome assembly
### 2.1. Running trinity software

Now we will obtain a <em>de novo</em> transcriptome using the trimmed paired end sequences. In the same script we will also calculate some stats on the obtained transcriptome. First, we will create two folders to store the analysis:

```
mkdir 4trinity #will contain the de novo transcriptome
```

We will create/edit a bash script to run `trinity` software (*trinity.run*) to obtain a <em>de novo</em> transcriptome.

```
#!/bin/bash

# jobs to launch
Trinity --left ./2trimmed_data/reads_1.P.fq.gz --right ./2trimmed_data/reads_2.P.fq.gz --seqType fq --normalize_reads --normalize_max_read_cov 30 --max_memory 6G --CPU 8 --output ./4trinity
```
To launch the trinity script in the cluster write on the terminal:
```
bash scripts/trinity.run
```

### 2.1. cd-hit: redundance reduction

Now we will avoid redundancy in the de novo transcriptome by using the `cd-hit` software. First we will create a folder to drop the analysis:

```
mkdir 5cdhit
```

First we will create/edit a bash script to run cd-hit software (*cd-hit.run*):

```
#!/bin/bash

cd-hit-est -i ./4trinity/Trinity.fasta -o ./5cdhit/Trinity_cdhit.fasta -c 0.9 -M 0 -T 8 > ./5cdhit/Trinity_cdhit.err

```
To launch the script in the cluster write on the terminal:
```
bash scripts/cd-hit.run
```

### 3. Post-processing

In this example we are analyzing the de novo transcriptome obtained with `trinity`, but we could apply the same analysis to the reduced fasta file obtained after running `cd-hit` software

### 3.1. Basic stats
We will check basic statistics of both trinity assembly and `cd-hit` reduced transcriptome

```
mkdir 6QC_trinity 
```

First we will create/edit a bash script to run the stats (*trinityQC.run*) to obtain a de novo transcriptome:

```
#!/bin/bash

# jobs to launch
TrinityStats.pl ./4trinity/Trinity.fasta > ./6QC_trinity/Trinity_assembly.metrics
TrinityStats.pl ./5cdhit/Trinity_cdhit.fasta > ./6QC_trinity/Trinity_cdhit_assembly.metrics

```
To launch the script in the cluster write on the terminal:
```
bash scripts/trinityQC.run
```

### 3.2. Representation of reads
In this step we will backmap the RNAseq reads to the de novo assembly to check the completeness of the transcriptome. The higher the precentge of reads that backmap, the better.

To do so, we will use the paired trimmed reads (which are those that we used for the de novo assembly) and the software `hisat2` for mapping.

First we will create/edit a bash script to run `hisat2` software (*hisat2.run*).

```
#!/bin/bash

# jobs to launch
hisat2-build ./4trinity/Trinity.fasta ./4trinity/Trinity
hisat2 -p 10 -x ./4trinity/Trinity -1 ./2trimmed_data/reads_1.P.fq.gz -2 ./2trimmed_data/reads_2.P.fq.gz -S ./6QC_trinity/reads.sam &> ./6QC_trinity/reads.sam.info
```

To launch the script in the cluster write on the terminal:
```
bash scripts/hisat2.run
```

### 3.3. From ncl to aa: TransDECODER

We will use `transdecoder` to get our predicted proteome. First, we will create a folder to drop the analysis, we will move to this folder and we will launch the analysis.

First we will create/edit a bash script to run `transdecoder` software (*transdecoder.run*):

```
mkdir 7proteome
```

```
#!/bin/bash

# jobs to launch

TransDecoder.LongOrfs -t ./4trinity/Trinity.fasta 
```

To launch the script in the cluster write on the terminal:
```
bash scripts/transdecoder.run
```

#### Bibliography

Grabherr MG, Haas BJ, Yassour M, Levin JZ, Thompson DA, Amit I, Adiconis X, Fan L, Raychowdhury R, Zeng Q, Chen Z, Mauceli E, Hacohen N, Gnirke A, Rhind N, di Palma F, Birren BW, Nusbaum C, Lindblad-Toh K, Friedman N, Regev A. Full-length transcriptome assembly from RNA-seq data without a reference genome. Nat Biotechnol. 2011 May 15;29(7):644-52. doi: 10.1038/nbt.1883. PubMed PMID: 21572440.


Haas BJ, Papanicolaou A, Yassour M, Grabherr M, Blood PD, Bowden J, Couger MB, Eccles D, Li B, Lieber M, Macmanes MD, Ott M, Orvis J, Pochet N, Strozzi F, Weeks N, Westerman R, William T, Dewey CN, Henschel R, Leduc RD, Friedman N, Regev A. De novo transcript sequence reconstruction from RNA-seq using the Trinity platform for reference generation and analysis. Nat Protoc. 2013 Aug;8(8):1494-512. Open Access in PMC doi: 10.1038/nprot.2013.084. Epub 2013 Jul 11. PubMed PMID:23845962.
