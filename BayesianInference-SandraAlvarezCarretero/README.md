# Bayesian Inference in `RevBayes`

----

Main content developed by: **Isabel Sanmartin**<br>
Contributor: **Sandra Álvarez-Carretero**<br>
Instructor: **Sandra Álvarez-Carretero**<br>

----

During this practical session, I will introduce you to [`RevBayes`](https://revbayes.github.io), an interactive environment for all types of Bayesian Inference analyses.

You can download `RevBayes` for your own use from [the `Downloads` section on the `RevBayes` website](https://revbayes.github.io/download). You shall find compiled binaries for Windows and Mac OSX, as well as a singularity image for Linux. Users can also compile `RevBayes` from the source code, which might be a good idea since this is the most up to date version of th eprogram.

The `RevBayes` website also posts incredibly detailed tutorial, [which can also find on the `Tutorials` section](https://revbayes.github.io/tutorials/), including the theory behind the methods.
Make the most out of these resources and... USE THEM!

## Software description and hints

* `RevBayes` is a "command line" program, which means that it does not have a graphical user interface, and we must interact with it through the Terminal/Console.
* Mathematical and operational functions in `RevBayes` are written in the object-oriented programming language C++. This makes `RevBayes` computationally efficient for even the most complex analyses.
* Additionally, `RevBayes` uses a scripting language to call functions and provide arguments: the `Rev` language. It is similar to `R` but more heavily scripted.
* `RevBayes` is a multi-purpose software, meaning that, in addition to phylogenetics, it can be used for molecular dating, trait evolution, diversification analysis, biogeography, epidemiology, etc.

## Data download and setting up `RevBayes`

We will be using a Docker container that has been generated for this course, where `RevBayes` has already been installed. If you want to run `RevBayes` on your own computer, you will first need to download the software in the version that is appropriate for your operating system (see [the `Downloads` section on the `RevBayes` website](https://revbayes.github.io/download)).

Once you decide whether you are using the Docker container or your own computer, we will be retrieving the [resources we will be going through during this practical session from the GitHub repository `ppgcourse2024`](https://github.com/ppgcourseUB/ppgcourse2024/). Please follow the guidelines below depending on what you have decided to use:

### Running `RevBayes`

#### Using a Docker container

Please make sure you can use the Docker container if you do not have `RevBayes` installed on your PC. Before running the commands below, please make sure that the Docker desktop app is running before! Otherwise, the `docker` commands will not work (issue found for WSL users and, most likely, that may also happen with Mac OSX users). Once you have the desktop app running, you should follow the next steps:

* Open a Terminal and check the Docker image ID and its name by typing the command `docker images`. Under `IMAGE_ID` you will see the ID given to the Docker image that is used to load the container, and under `REPOSITORY` you shall see the name of the container (e.g., use `ppgcourseub` if you have not changed the name). An example of what you can see when you run this command is illustrated below:

    ```sh
    # Run the command to check image ID and name
    docker images
    ```

    Your output may resemble the text displayed below:

    ```txt
    # REPOSITORY            TAG        IMAGE ID       CREATED      SIZE
    # ppgcourseub/ppg24   latest      7039bb0e5351   42 hours ago   17.3GB
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

* Now, please activate the `conda` environment for `RevBayes`:

  ```sh
  # Activate environment
  conda activate revbayes
  # Check that it runs
  rb
  ```

  If `RevBayes` is running, you should see that the `RevBayes` console is now displayed and you can start working by typing your commands after the symbol `>`:

  ```text
    RevBayes version (1.0.12)
    Build from  () on Mon May 15 20:22:47 UTC 2023

    Visit the website www.RevBayes.com for more information about RevBayes.

    RevBayes is free software released under the GPL license, version 3. Type 'license()' for details.

    To quit RevBayes type 'quit()' or 'q()'.

    >
  ```

* Once you are finished with the `RevBayes` console, you can type `q()` or press `ctrl+C`.
* When you want to exit the container, please type `exit` and you shall return to your screen with your user prompt. Please make sure you stop the container by typing the following command on your terminal:

    ```sh
    docker stop ppgcourseub
    ```

#### Using your own PC

If you are to install `RevBayes` on your PC, please follow the installation guidelines when you download [the program from the `Downloads` section on the `RevBayes` website](https://revbayes.github.io/download).

* If you have exported the path to the executable file that launches `RevBayes`, you can type `rb` on the Terminal and you will see the graphical interface described in the previous section if everything works. Make sure that you give it executable permissions (e.g., `chmod 775 rb`) so that you can execute it!
* If you have not exported such path, you will need to copy the `rb` file (either the pre-compiled binary or the one you have created if you have compiled `RevBayes` from the source code) in the directory where you want to execute it. Make sure it has executable permissions and then run it by typing `./rb`.

### Cloning the repository and accessing the data

Once you are ready to get started with `RevBayes`, either by using the Docker container or your own PC, please clone this repository by following the guidelines below:

```sh
# Launch the next command from the location in your
# file structure where you want the repository to
# be saved
git clone https://github.com/ppgcourseUB/ppgcourse2024.git
# Access today's practical directory
cd cd BayesianInference-SandraAlvarezCarretero/
# Check that you can see `Lab_1` and `Lab_2` directories
ls
# You should see `Lab_1`, `Lab_2` and `README.md`.
```

### Sharing a local directory on your OS with the Docker container

If you have cloned the repository on your PC and want to share this directory with the Docker container, please use the instructions given below:

* Type the command `docker run -v <path_in_your_PC_to_the_repo>:<path_in_the_container_where_you_want_the_shared_repo> -it <name_container>`. Let's assume that the path to the repository in our OS is `/home/courses/2024/ppgcourse2024/ppgcourse2024_week1/BayesianInference-SandraAlvarezCarretero` and that we want it in `/home/ppguser/test` (i.e., you should have created a `test` directory inside your home directory before!). An example of how to run this command using the example above would be the following:

    ```sh
    docker run -v home/courses/2024/ppgcourse2024_week1/BayesianInference-SandraAlvarezCarretero:/home/ppguser/test -it ppgcourseub/ppg24
    ```

Please note that, once you stop the container (i.e., `docker stop ppgcourseub`), this directory will stop being shared. In other words, when you start and access the Docker container again, you will see that the shared directory will have disappeared. If you want to create this shared directory once more, you will need to run the command above again!

> [!NOTE]
> The shared directory that you will create in the Docker container resembles a "hard link". In essence, whatever changes you do in the container will also affect the directory saved in your PC. E.g., if you remove a file when working in the container, such file will also be removed in your PC. While sharing a directory is useful, you also need to be careful with what you do. When in doubt, create a backup on your PC that is not shared with your container!

## Let's get started

If you can run `RevBayes` and have access to the data we will be using during this practical session, then you are ready to go! Please click either `Lab_1` or `Lab_2` to start the first or the second practical session, respectively.

* [`Lab_1`](Lab_1/README.md): access the first practical session.
* [`Lab_1`](Lab_2/README.md): access the second practical session.

Happy Inference! :)
