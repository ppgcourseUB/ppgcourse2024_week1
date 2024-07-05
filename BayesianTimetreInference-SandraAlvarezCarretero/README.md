# Bayesian timetree inference

## DISCLAIMER

This tutorial is based on the workflow and tutorials I host in my GiHub repository ([`Tutorial_MCMCtree`](https://github.com/sabifo4/Tutorial_MCMCtree)). I am actively implementing new features and tutorials as part of the current workflow of this pipeline as well as developing new scripts/tools. In other words, the code is not stable and I am still validating new features. If you use this tutorial and/or scripts for your research, **please <a href="mailto:sandra.ac93@gmail.com"><b>contact me</b></a> to make sure you are using the latest version**. In addition, **please cite the following**:

* Álvarez-Carretero S. (2024). sabifo4/Tutorial_MCMCtree: v1.0.0 (tutorialMCMCtree-prerelease). Zenodo. https://doi.org/10.5281/zenodo.11306642
* Álvarez-Carretero, Tamuri, et al. A species-level timeline of mammal evolution integrating phylogenomic data. Nature 602, 263–267 (2022). https://doi.org/10.1038/s41586-021-04341-1

If you have any questions, please do not hesitate <a href="mailto:sandra.ac93@gmail.com"><b>to reach out</b></a>.<br>

Thank you :)

----

Content developed by: **Sandra Álvarez-Carretero**<br>
Instructor: **Sandra Álvarez-Carretero**<br>

----

## Overview

During this practical session, we will use various in-house scripts and tools together with `BASEML` and `MCMCtree`, two programs that are part of the `PAML` software ([Yang 2007](https://pubmed.ncbi.nlm.nih.gov/17483113/)), to run a **Bayesian node-dating analysis** with `MCMCtree` when using the **approximation to the likelihood calculation** ([dos Reis and Yang, 2011](https://academic.oup.com/mbe/article/28/7/2161/1051613)) to speed up timetree inference.

Before you get started, let's look at the data that you have managed to collect so far:

* [**Molecular alignment**](00_inp_data): all files that start with `aln_*` were inferred with `BAli-Phy` ([Redelings, 2021](https://academic.oup.com/bioinformatics/article/37/18/3032/6156619)) using the CYTB sequences of 8 mammals downloaded from the NCBI web server, then converted into PHYLIP format. For more information on how this molecular alignment has been generated, you can always [read the step-by-step tutorial in the `data_processing` directory](data_processing/README.md). To make sure you have time to go through this tutorial, however, please do not go through this dataset assembly pipeline until the end of this session.
* [**Set of calibrations**](00_inp_data/calibs/inp_calibs/Calibnodes_cytb.csv): node age constraints to calibrate the phylogeny to geological time established according to our interpretation of the fossil record. The [`Include_calibrations_MCMCtree.R`](00_inp_data/calibs/scripts/Include_calibrations_MCMCtree.R) first used the raw calibration information ([`calibrations.txt`](00_inp_data/calibs/raw_calibs/calibrations.txt)) to generate [an intermediate file](00_inp_data/calibs/raw_calibs/cals_only_cytb.tree) that is subsequently used by another script ([`Merge_node_labes.R`](02_MCMC_diagnostics/scripts/Merge_node_labels.R)) to generate the final [`Calibnodes_cytb.csv`](00_inp_data/calibs/inp_calibs/Calibnodes_cytb.csv) file. We will not have time to learn how to go through this process but, given that the R scripts are well documented, feel free to go through them after this practical session!
* [**Calibrated phylogeny**](00_inp_data/cytb_calib_MCMCtree.tree): calibrated phylogeny generated with the R script [`Include_calibrations_MCMCtree.R`](00_inp_data/calibs/scripts/Include_calibrations_MCMCtree.R). The phylogeny (i.e., tree topology with branch lengths) was inferred with `BAli-Phy` ([Redelings, 2021](https://academic.oup.com/bioinformatics/article/37/18/3032/6156619)). For more information about how this phylogeny was  inferred, you can always [read the step-by-step tutorial in the `data_processing` directory](data_processing/README.md). To make sure you have time to go through this tutorial, however, please do not go through this dataset assembly pipeline until the end of this session.

Remember that, before proceeding with timetree inference, you need to get familiar with your dataset! For instance, you may ask yourselves questions such as "how were the data collected?", "how were the alignments generated?", or "how are the files going to be organised?". In this practical session, we are not going to address such questions as we will only have time to focus on the subsequent steps. Nevertheless, at the end of the session, you can always go through the step-by-step data assembly workflow available in the [`data_processing` directory](data_processing) to understand how the data were collected and processed. To learn more about the different steps that the phylogenomic workflow consists of, you may also want to read [Álvarez-Carretero & dos Reis, 2022](https://link.springer.com/chapter/10.1007/978-3-030-60181-2_13).

## Goals

At the end of this practical session, you should...

* ... be mindful about how important it is to be familiar with your dataset before proceeding with timetree inference.
* ... understand the format that input data and control files require to run timetree inference analyses with `PAML` programs.
* ... understand how to run `PAML` programs for timetree inference analysis. E.g., specifying substitution models, selecting the most adequate priors according to your dataset, specifying MCMC settings, etc.
* ... understand how to run MCMC diagnostics to confidently assess whether your chains have potentially reached converged and how you can filter them before proceeding to summarise the results with the samples collected during the MCMC.
* ... be able to critically discuss the results you have obtained according to your prior hypotheses and the settings under which the programs have been executed.

## Workflow

The summary of the workflow that you will go through during this practical session is described below:

* Running `PAML` software for timetree inference:
  * Using various in-house pipelines to set up the working environment, the file structure, and the control files required to run `PAML` software -- feel free to go back to the lecture content if you have questions about the options that are to be specified in `PAML` control files (e.g., nucleotide substitution model, tree prior, rate prior, MCMC settings, etc.).
  * Running `BASEML` to calculate the branch lengths, the gradient, and the Hessian, which `MCMCtree` will subsequently use to enable the approximate likelihood calculation to speed up timetree inference.
  * Running `MCMCtree`. We will carry out the following analyses to assess the impact that different relaxed-clock models and partitioning schemes can have on time estimates. Particularly, we will assess the following:
    * Relaxed-clock models
      * **Geometric Brownian motion (GBM)** model ([Thorne et al. 1998](http://www.ncbi.nlm.nih.gov/pubmed/9866200), [Yang and Rannala 2006](http://www.ncbi.nlm.nih.gov/pubmed/16177230)): autocorrelated-rates model.
      * **Independent log-normal rate (ILN)** model ([Rannala and Yang 2007](http://www.ncbi.nlm.nih.gov/pubmed/17558967), [Lemey et al. 2010](http://www.ncbi.nlm.nih.gov/pubmed/20203288)): uncorrelated-rates model
    * Partitioning schemes
      * **All codon positions (123CP)**: one alignment block with one gene alignment with all codon positions.
      * **Only first and second codon positions (12CP)**: one alignment block with only the first and the second codon positions.
      * **Partitioned alignment (12CP-3CP)**: one alignment block with only the first and the second codon positions and a second alignment block with only the third codon positions.
* Carry out the MCMC diagnostics for all the chains that ran under the following analyses:
  * **GBM_123CP**: GBM relaxed-clock model + one alignment block with all CPS.
  * **GBM_12CP**: GBM relaxed-clock model + one alignment block with only 1st+2nd CPs.
  * **GBM_12CP-3CP**: GBM relaxed-clock model + two alignment blocks (1: 1st+2nd CPs | 2: 3rd CPs).
  * **ILN_123CP**: ILN relaxed-clock model + one alignment block with all CPS.
  * **ILN_12CP**: ILN relaxed-clock model + one alignment block with only 1st+2nd CPs.
  * **ILN_12CP-3CP**: ILN relaxed-clock model + two alignment blocks (1: 1st+2nd CPs | 2: 3rd CPs).
* General discussion.

> [!NOTE]
>
> * We will go through these steps together so that everyone can follow all the steps involved in using `PAML` for timetree inference.
> * We will stop 15 minutes before the end of the practical session to discuss the results that you have obtained by that time. If we have not finished the analyses, please do not worry! I will share with you the results (or you can run these analyses later), and we can all have a general discussion about how different  partitioning schemes and relaxed-clock models have affected the estimated divergence times in our bear phylogeny.

## Software

We will be using a Docker container that has been generated for this course, where `PAML` v4.10.7 has already been installed. If you want to run `PAML` programs on your own computer, you will first need to download the software in the version that is appropriate for your operating system (see [instructions below](README.md#running-paml-on-your-pc)).

Once you decide whether you are using the Docker container or your own computer, you can retrieve the [resources we will be going through during this practical session from the GitHub repository `ppgcourse2024`](https://github.com/ppgcourseUB/ppgcourse2024_week1). Please follow the guidelines below depending on what you have decided to use:

### Running `PAML` on a Docker container

Please make sure you can use the Docker container if you have not installed `PAML` on your PC. You should follow the next steps:

* Open a Terminal and check the Docker image ID and its name by typing the command `docker images`. Under `IMAGE_ID` you will see the ID given to the Docker image that is used to load the container, and under `REPOSITORY` you shall see the name of the container (e.g., use `ppgcourseub` if you have not changed the name). An example of what you can see when you run this command is illustrated below:

    ```sh
    # Run the command to check image ID and name
    docker images
    ```

    Your output may resemble the text displayed below:

    ```txt
    # REPOSITORY          TAG          IMAGE ID       CREATED      SIZE
    ppgcourseub/ppg24   latest      7039bb0e5351   42 hours ago   17.3GB
    ```

* Now, run the Docker container! Depending on whether it is the first time or not, you will use different commands:
  * If it is the first time you are running the container, you need to use the command `docker run -it --name=NAMEDOCK IMAGE_ID /bin/bash`, where you need to replace `IMAGE_ID` with the Docker image ID (e.g., `7039bb0e5351` in the example above) and `NAMEDOCK` with the name of the container (e.g., `ppgcourseub` in the example above). If using the example above, the command would look like the following:

    ```sh
    docker run -it --name=ppgcourseub 7039bb0e5351 /bin/bash
    ```

  * If you have already accessed the container before, please type `docker start NAMEDOCK` followed by`docker exec -it NAMEDOCK /bin/bash`, where `NAMEDOCK` is to be replaced by the name of the container (e.g., `ppgcourseub` in the example above). If using the example above, the commands would look like the following:

    ```sh
    docker start ppgcourseub
    docker exec -it ppgcourseub /bin/bash
    ```

* Once you have launched the Docker container, you will see that your user prompt on the Terminal changes. E.g.: you should see something like the follow (the string after the `@` symbol may be different):

    ```Console
    ppguser@b0cb6f507e26:~$
    ```

* Now, type `mcmctree` and press the return key:

  ```Console
  ppguser@187c8597dfac:~$ mcmctree
  ```

  If `PAML` has been properly installed, you should see the following message printed on the screen:

  ```text
    MCMCTREE in paml version 4.10.7, June 2023
    
    error when opening file mcmctree.ctl
    tell me the full path-name of the file?
  ```

  This error message helps us understand that `MCMCtree` can correctly run on the container. In essence, we are just being told that `MCMCtree` requires a control file to run, which we have not provided the program with. By typing `mcmctree`, we just wanted to test whether this program could run (i.e., the path to the binary has been exported to the system), and indeed it can! You can do the same by typing `baseml`, another `PAML` program we will use during the practical session.

* When you want to exit the container, please type `exit` and you shall return to your screen with your user prompt. Please make sure you stop the container by typing the following command on your terminal:

    ```sh
    docker stop ppgcourseub
    ```

### Running `PAML` on your PC

If you want to run this practical session on your PC, please make sure you have the following software installed:

* **`PAML`**: you will be using the latest `PAML` release ([at the time of writing, v4.10.7](https://github.com/abacus-gene/paml/releases/tag/4.10.7)), available from the [`PAML` GitHub repository](https://github.com/abacus-gene/paml). If you do not want to install the software from the source code, then follow (A). If you want to install `PAML` from the source code, then follow (B). If you have a Mac with the latest chips (or if you have other chips but neither option A or B work for you), please follow (C):

  * Installation (A): if you have problems installing `PAML` from the source code or you do not have the tools required to compile the source code, then you can [download the pre-compiled binaries available from the latest release by following this link](https://github.com/abacus-gene/paml/releases/tag/4.10.7). Please choose the pre-compiled binaries you need according to your OS, download the corresponding compressed file, and save it in your preferred directory. Then, after decompressing the file, please give executable permissions, export the path to this binary file so you can execute it from a terminal, and you should be ready to go!
    > **Windows users**: I suggest you install the Windows Subsystem for Linux (i.e., WSL) on your PCs to properly follow this tutorial -- otherwise, you may experience problems with the Windows Command Prompt. Once you have the WSL installed, then you can download the binaries for Linux.
  * Installation (B): to install `PAML` from the latest source code, please follow the instructions given in the code snippet below:

    ```sh
    # Clone to the `PAML` GitHub repository to get the latest `PAML` version
    # You can go to "https://github.com/abacus-gene/paml" and manually clone
    # the repository or continue below from the command line
    git clone https://github.com/abacus-gene/paml
    ##> NOTE: You can also download the source code from the latest release
    ##> if you want to download a stable version!
    ##> https://github.com/abacus-gene/paml/releases
    # Change name of cloned directory to keep track of version
    mv paml paml4.10.7
    # Move to `src` directory and compile programs
    cd paml4.10.7/src
    make -f Makefile
    rm *o
    # Move the new executable files to the `bin` directory and give executable
    # permissions
    mkdir ../bin
    mv baseml basemlg chi2 codeml evolver infinitesites mcmctree pamp yn00 ../bin
    chmod 775 ../bin/*
    ```
  
    Now, you just need to export the path to the `bin` directory where you have saved the executable file. If you want to automatically export this path to your `./bashrc`/`~/.zshrc`/`~/.bash_profile`/<you_name_it> (i.e., file name depends on your OS), you can run the following commands **AFTER ADAPTING the absolute paths written in the code snippet below to those in your filesystem**:

    ```sh
    # Run from any location. Male sure you change 
    # `~/.bashrc` if you are using another file!
    printf "\n# Export path to PAML\n" >> ~/.bashrc
    # Replace "/c/usr/Bioinfor_tools/" with the path
    # that leads to the location where you have saved the
    # `paml4.10.7` directory. Modify any other part of the
    # absolute path if you have made other changes to the 
    # name of the directory where you have downloaded `PAML`
    printf "export PATH=/c/usr/bioinfo_tools/paml4.10.7/bin:\$PATH\n" >>  ~/.bashrc
    # Now, source the `~/.bashrc` file (or the file you are 
    # using) to update the changes
    source ~/.bashrc
    ```

    Alternatively, you can edit this file using your preferred text editor (e.g., `vim`, `nano`, etc.).
    > **Windows users**: I suggest you install the Windows Subsystem for Linux (i.e., WSL) on your PCs to properly follow this tutorial -- otherwise, you may experience problems with the Windows Command Prompt. Once you have the WSL installed, then download the source code and follow the instructions listed above.

* Installation (C) for M1/M2 chips or Mac users with other chips that experience problems with options A and/or B (Mac OSX): you will need to download the `dev` branch on the `PAML` GitHub repository and compile the binaries from the `dev` source code. Please [follow this link](https://github.com/abacus-gene/paml/tree/dev) and click the green button [`<> Code`] to start the download. You will see that a compressed file called `paml-dev.zip` will start to download. Once you decompress this file, you can go to directory `src` and follow the instructions in (B) to compile the binaries from the source code. If you wanted to do this from the terminal, you could also clone the repository as explained above and then change the branch using command `git checkout dev`.

### Running `R` and `RStudio`

The Docker container will already have `R` installed, which you will use to parse various input and output files througout this practical session. Note that all the MCMC diagnostics will take place using a combination of in-house bash and R scripts, so it is important that you have `R` and `RStudio` on your PC! Below, you can find a list of what you will need to install on your PC to complete this part of the practical session:

* **`R`** and **`RStudio`**: please download [R](https://cran.r-project.org/) and [RStudio](https://posit.co/download/rstudio-desktop/) as they are used throughout the tutorial. The packages we will be using should work with `R` versions that are either newer than or equal to v4.1.2. If you are a Windows user, please make sure that you have the correct version of `RTools` installed, which will allow you to install packages from the source code if required. For instance, if you have `R` v4.1.2, then installing `RTools4.0` shall be fine. If you have another `R` version installed on your PC, please check whether you need to install `RTools 4.2` or `RTools 4.3`. For more information on which version you should download, [please go to the CRAN website by following this link and download the version you need](https://cran.r-project.org/bin/windows/Rtools/).

    Before you proceed, however, please make sure that you install the following packages too:

    ```R
    # Run from the R console in RStudio
    # Check that you have at least R v4.1.2
    version$version.string
    # Now, install the packages we will be using
    # Note that it may take a while if you have not 
    # installed all these software before
    install.packages( c('rstudioapi', 'ape', 'phytools', 'sn', 'stringr', 'rstan', 'devtools' ), dep = TRUE )
    devtools::install_github( "dosreislab/mcmc3r" )
    ## NOTE: If you are a Windows user and see the message "Do you want to install from sources the 
    ## packages which need compilarion?", please make sure that you have installed the `RTools`
    ## aforementioned.
    ```

    To exit the R console, just type `q()`. You do not need to save the workspace, so you can type `n`.

> [!NOTE]
> If you are trying to install the R packages via the command line on your PC, make sure you also install the following packages before installing the R packages if you are using Linux or the WSL:
>
> ```sh
> sudo apt install build-essential libcurl4-gnutls-dev libxml2-dev libssl-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
> ```

### Other programs you will need to have installed on your PC

To parse and visualise the output files generated throghout this practical, **you will need to have installed the following programs on your PC even if you are using the Docker container**:

* If the Docker container does not have the `devtools` or the `mcmc3r` R packages installed, you will have to install them. You can check whether they are available by accessing the container and typing `R` on the Terminal to access the `R` interface. Then, please type `libary("devtools")` and `library("mcmc3r")`: if you get no errors you are fine!. If they are not installed, please run the following commands on your container:

  ```sh
  # 1. Log in R
  R
  # 2. After logging in R, install the two required packages
  #    Select the server that is closer to your location!
  install.packages( "devtools" )
  devtools::install_github( "dosreislab/mcmc3r" )
  ```

  To exit the R console, just type `q()`. You will not need to save the workspace, so type `n`.

* **`TreeViewer`**: you can use `TreeViewer` ([Bianchini and Sánchez-Baracaldo, 2024](https://onlinelibrary.wiley.com/doi/10.1002/ece3.10873)) as a graphical interface with which you can display and highlgy customise the format of the timetrees we will generate during this practical. You may want to read [the `TreeViewer` documentation](https://github.com/arklumpus/TreeViewer/wiki) to learn more about which modules you can use and how you can improve the design of your timetrees (e.g., include/exclude densities, include pictures, play with various colours and shapes, etc.). You can [download `TreeViewer` by following this link](https://treeviewer.org/).
* **`FigTree`**: alternatively, you can use `FigTree` to display the timetrees we will have generated. While not as customisable as `TreeViewer`, you can decide what you want to be displayed on the graphical interface by selecting the buttons and options that enable a specific design. You can [download the latest pre-compiled binaries, `FigTree v1.4.4`, from the `FigTree` GitHub repository](https://github.com/rambaut/figtree/releases).
* **`Tracer`**: you can use this graphical interface to visually assess the quality of the MCMCs you have run during the analyses with `MCMCtree` (e.g., chain efficiency, chain convergence, autocorrelation, etc.). You can [download the latest pre-compiled binaries, `Tracer v1.7.2` at the time of writing, from the `Tracer` GitHub repository](https://github.com/beast-dev/tracer/releases/tag/v1.7.2).
* **Visual Studio Code** (optional): for best experience with this practical session, I highly recommend you install Visual Studio Code and run everything within this platform to keep everything tidy, organised, and self-contained. You can download VSC from [their website](https://code.visualstudio.com/). If you are new to VSC, you can check their webinars to learn about its various features and how to make the most out of it. In addition, you may also want to install the following extensions:

  * Markdown PDF -- developer: yzane
  * markdownlint -- developer: David Anson
  * Spell Right -- developer: Bartosz Antosik
  * vscode-pdf -- developer: tomoki1207

## Cloning the repository and accessing resources

Once you are ready to get started with this practical session, either by using the Docker container or your own PC, please clone this repository by following the guidelines below:

```sh
# Launch the next command from the location in your
# file structure where you want the repository to
# be saved -- chose option 1 or option 2 depending
# on where you are running the practical session

# 1. You can clone the whole repository in your own PC:
git clone https://github.com/ppgcourseUB/ppgcourse2024_week1.git
# Access today's practical directory
cd BayesianTimetreInference-SandraAlvarezCarretero/

# 2. If your are within an executed container:
ghget https://github.com/ppgcourseUB/ppgcourse2024_week1/blob/main/BayesianInference-SandraAlvarezCarretero/
# if this command does not run for you, check the email with the instructions to download the repository in the /tmp foder and move the files to the ppguser directory using ghget
```

### Sharing a local directory on your OS with the Docker container

If you are using a Docker container but you have cloned the repository on your PC, you may want to share this directory with the Docker container so that it is easier to visualise the results with some of the graphical interfaces that you can only use on your PC. If that is the case, please use the instructions given below:

* Type the command `docker run -v <path_in_your_PC_to_the_repo>:<path_in_the_container_where_you_want_the_shared_repo> -it <name_container>`. Let's assume that the path to the repository in our OS is `/home/courses/2024/ppgcourse2024/ppgcourse2024_week1/BayesianTimetreeInference-SandraAlvarezCarretero` and that we want it in `/home/ppguser/test` (i.e., you should have created a `test` directory inside your home directory before!). An example of how to run this command using the example above would be the following:

    ```sh
    docker run -v home/courses/2024/ppgcourse2024_week1/BayesianTimetreeInference-SandraAlvarezCarretero:/home/ppguser/test -it ppgcourseub/ppg24
    ```

Please note that, once you stop the container (i.e., `docker stop ppgcourseub`), this directory will stop being shared. In other words, when you start and access the Docker container again, you will see that the shared directory will have disappeared. If you want to create this shared directory once more, you will need to run the command above again!

> [!NOTE]
> The shared directory that you will create in the Docker container resembles a "hard link". In essence, whatever changes you do in the container will also affect the directory saved in your PC. E.g., if you remove a file when working in the container, such file will also be removed in your PC. While sharing a directory is useful, you also need to be careful with what you do. When in doubt, create a backup on your PC that is not shared with your container!

## Data analysis

If you have gone through the previous sections and have a clear understanding of the dataset you will be using, the workflow of the analyses you will be running, and have installed the required software to do so... Then you can start to analyse our bear dataset [by following this link](01_timetree_inference/README.md).

Happy timetree inference! :)

----

ⓒ Dr Sandra Álvarez-Carretero | [`@sabifo4`](https://github.com/sabifo4/)
