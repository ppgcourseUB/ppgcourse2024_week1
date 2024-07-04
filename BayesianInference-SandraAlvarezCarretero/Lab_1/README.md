# Lab 1: Introduction to `RevBayes`

## Launching `RevBayes`

### Using a Docker container

From the terminal, launch `RevBayes` by typing the following:

```sh
rb
```

This should launch `RevBayes` and give you a command prompt (the `>` character); this means `RevBayes` is waiting for input. The *working directory* is the directory that `RevBayes` is currently working in. When you tell `RevBayes` to look up a file in a particular path, the path you provide is interpreted *relative* to the working directory. You can print the current working directory using the `getwd()` command.

### From your computer

Navigate to your `Lab_1` directory and proceed accordingly:

* Windows users without WSL: simply double click on the executable `rb`
* Windows users with WSL, Linux users, and Mac OSX users: open a Terminal and type `rb` if you have exported the program to the path. If not, copy the executable inside `Lab_1` and type `./rb`.

If you follow the instructions above, you should launch `RevBayes` and see the command prompt (the `>` character); this means `RevBayes` is waiting for input. The *working directory* is the directory that `RevBayes` is currently working in. When you tell `RevBayes` to look up a file in a particular path, the path you provide is interpreted *relative* to the directory where you launched `RevBayes`. You can print the current working directory using the `getwd()` command.

----

<details>
<summary><b>Notes from previous editions when using an HPC (please ignore, only here for the record)</b></summary>
<br>

We will be working in the cluster *interactively*

First, access the data files and scripts for the practice. Access the lab cluster via the Terminal in MacOSX and Linux, or the Console in Windows machine, with the `ssh`, as you learnt at the *Intro to our cloud* practice.

```sh
ssh user@ec2-34-242-61-70.eu-west-1.compute.amazonaws.com
```

where the *user* are your credentials. It will ask for your password. Once inside, clone the entire folder *Bayesian_Inference_ISABEL_SANMARTIN* with the `svn` command. This will copy all files and folders in your home directory within the cluster.

```sh
svn export https://github.com/ppgcourseUB/ppgcourse2023/trunk//Bayesian_Inference_ISABEL_SANMARTIN
```

Check the contents of the folder. There are two subfolders named `Lab`. We will start with `Lab_1`, which introduces the `RevBayes` software and the `Rev` language. To see the contents of the folder, you need to move with the `cd` command

```sh
cd Lab_1
ls
```

You would see that there are several files, including scripts and data we need for the practice: `Intro.Rev`, `myScript.sh`, and `myScript-cluster.sh`

> [!NOTE]
> The scripts and files should be downloaded into the folder containing the `RevBayes` executable (the `rb` binary in the Mac). Inside this folder, create a new folder `Lab_1` and copy the `Intro.Rev` and `myScript.sh` files into this folder.

```sh
mkdir Lab_1
cp -p Intro.Rev Lab_1/
cp -p myScript.sh Lab_1/
```

To launch `RevBayes` using the version already installed in the cluster, first load the module, using the commands you learnt in the *Intro* class:

```sh
module load revbayes/1.1.1-zjzfb6s
```

Then, launch `RevBayes`, type:

```sh
rb-mpi
```

(notice that the version installed in the cluster is the MPI version (message passage interface), which allows running the software using multiple threads or processors)

This should launch `RevBayes` and give you a command prompt (the `>` character); this means `RevBayes` is waiting for input.

</details>

----

## Learning the basic structure of the `Rev` language

### Mathematical operations

`Rev` is an interpreted language for statistical computing and phylogenetic analysis. Therefore, the basics are simple mathematical operations. Entering each of the following lines into the `RevBayes` prompt will execute these operations. You can also execute multiple operations in one line if you separate them with a semicolon.

```r
# Simple mathematical operators:
1 + 1             # Addition
5 * 5             # Multiplication
2^3               # Exponentiation
4 % 2             # Modulus when remainder is 0
                  # 4 / 2 = 2
                  # 4 % 2 = 0 (remainder after the division, cannot be larger than 2)
                  # 2 * 0 + 4 = 4 (cannot be larger than 4)
5 % 7             # Modulus when remainder is not 0
                  # 5 / 7 = 0
                  # 5 % 7 = 7 (it still remains 5, cannot be larger than 7)
                  # 0 * 7 + 5 = 5 (cannot be larger than 5)
1 + 3; 4 / 2      # Multiple statements in one line
```

### Functions

Functions are commands that perform more complex procedures than the above operations. Notice that `RevBayes` is case-sensitive, so `exp(1)` will work but `Exp(1)` will give you an error.

```r
# Math functions:
exp(1)            # exponential function
ln(1)             # natural logarithmic function
sqrt(16)          # square root function
power(2,2)        # power function: power(a,b) = a^b
```

### Variables

One of the most important features of `RevBayes` is the ability to declare and assign variables. There are three types of variables, called *constant*, *deterministic*, and *stochastic* variables. Variables are also the "nodes" in the directed acyclical graphs that are used to create the `RevBayes` models.

*Constant variables* contain values that adopt fixed values. The left arrow (`<-`) creates a constant variable and automatically assign the following value to it. Here, we create the constant node `a` and assign a value of `1`. We can print the value by typing `a` and pressing enter.

```r
# Variable assignment: constant
a <- 1 # assignment of constant variable 'a'
a      # printing the value of 'a'
```

*Deterministic variables* are variables whose value depends on another random variable: the value changes when the variable they depend on change via a function or transformation. They are created with the colon-equal assignment (`:=`). Here, we create a deterministic variable, `b`, whose values are dependent on the value assigned to `a` via the exponential function `exp(a)`.

```r
# Variable assignment: deterministic
# Assign a mathematical function in which
# a constant variable is used
b := exp(a)
b # print the value of 'b' ("2.718282")
# Assign another value to 'a', which will 
# change the value of 'b'
a <- 2
b # print the new value of 'b' ("7.389056")
```

*Stochastic variables* are random variables whose values are drawn from a statistical distribution with its own parameters. Because they are random, values will change during the analysis. They are created with the tilde assignment (`~`). Here, we create a stochastic variable `x` that is drawn from an exponential distribution with rate parameter (`lambda`).

```r
# Variable assignment: stochastic
# First, we assign a value to the lambda parameter governing the exponential distribution
lambda <- 1.0
# Next, we create the stochastic variable with values drawn from this exponential distribution
x ~ dnExponential(lambda)
x # print value of stochastic node 'x' ("1.256852") 
```

### Vectors

Vectors are containers that contain multiple variables of the same type. To create a vector with values

```r
# Create a vector "implicitly"
Z <- v(1.0,2.0,3.0) 
Z # print the vector ("[ 1.000, 2.000, 3.000 ]")

# Alternatively, fill an empty vector element
# by element
# First, create the empty vector
Y <- rep(0,3) # repeat 0 three times
Y # print the empty vector [ 0, 0, 0 ]
# Now, fill it out!
Y[1] <- 1.0 # make the first element 1.0
Y[2] <- 2.0 # make the second element 2.0
Y[3] <- 3.0 # make the third element 3.0
Y # print the vector ("[ 1.000, 2.000, 3.000 ]")
```

### `for` Loops

`for` loops are important programming structures that allow you to repeat the same statement a number of times on different variables. This simple `for` loop creates the variable `i`, and for each value of `i` from 1 to 100, prints the value of `i` to the screen ("1, 2, 3, 4... 100").

```r
for ( i in 1:100 ) {
  i
}
```

## Quitting `RevBayes`

When we're done with `RevBayes`, or want to relaunch the program, we can quit using the `q()` command:

```r
# Quitting RevBayes
q()
```

If you want to learn more about the `Rev` language, please consult [`Rev` language reference on the `RevBayes` website](https://revbayes.github.io/documentation/mvAddRemoveTip.html)!

## Scripts

So far, we have been using `RevBayes` *interactively*: by typing commands in line-by-line. Most often, however, we use *scripts*: a text file that contains a sequence of commands for the program to execute.

You can *source* the contents of a script from `RevBayes` using the `source("name of file")` command (the quotation marks are critical!). Source the `Intro.Rev` script that contains all commands above:

```r
# Launch RevBayes
rb
# Make sure you are in the correct directory
# where the script it, then see whether the
# script is there
getwd()
listFiles(".")
# Source the script
source("Intro.Rev")
```

Alternatively, you can run the script file from the Terminal directly (outside `RevBayes`) using the command `rb` (OBS: In this case, we don't need the quotation marks!):

```sh
# Launch from the directory where the bash script 
# can be found
rb Intro.Rev
```

You can also run it from a bash script from your Terminal. You can find an example of such a script on `myScript.sh`, which content you can find below:

```text
#!/bin/bash
rb Intro.Rev
exit
```

To run the bash script `myScript.sh`, you can use the commands below:

```sh
# Launch from the directory where the bash script 
# can be found
#
# Option 1
bash myScript.sh
# Option 2
./myScript.sh
```

----

<details>
<summary><b>Notes from previous editions when using an HPC (please ignore, only here for the record)</b></summary>
<br>

Finally, we can use a bash file if we are running the script within a cluster. Below, is an example of a bash file to run the `Intro.Rev` script in `RevBayes`. Because we are running in a cluster, we need to include a command for the output to be saved. You can find this script `myScript-cluster.sh` in the `Lab_1` folder.

```sh
#!/bin/bash

#SBATCH -p norma
#SBATCH -n 8
#SBATCH -c 1
#SBATCH --mem=6GB
#SBATCH --job-name orthofinder-job01
#SBATCH -o %j.out
#SBATCH -e %j.err

module load revbayes

mpirun -np 8 rb-mpi Intro.Rev
```

And to submit the job to SLURM

```sh
sbatch myScript-cluster.sh
```

And to check the progress

```sh
squeue
```

The results are inside the *[filename].out* file. You can read it with the command `less`, or with a text processor program such as VIM or AWK

</details>

----

<br>

----

## Exercises

1. Exit and restart `RevBayes`. Create a fresh, blank script in a text editor. You can use Vim or AWK, as you learnt the first day. Alternatively, you can type directly at the `RevBayes` prompt.
2. Create a variable called `z` with the value `10`. What kind of variable is this?
3. Create a second variable `y` which is `y := ln(z)`. What kind of variable is `y`? What is its value?
4. Change the value of `z` to `100`. Before printing `y`, can you guess if the value will be lower or higher?
5. Write a `for` loop that creates a variable `i`, and for each value of `i` from 1 to 100, creates a second variable `z`, which is a deterministic function of `f(i) = 2 * i`, and then prints all the values of `z` to the screen. Then, using the `mean()` function, calculate the mean of those numbers.
