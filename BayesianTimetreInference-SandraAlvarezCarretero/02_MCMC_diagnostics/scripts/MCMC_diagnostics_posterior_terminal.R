#!/usr/bin/env Rscript

#-------------------#
# CLEAN ENVIRONMENT #
#-------------------#
rm( list = ls( ) )

#----------------#
# LOAD ARGUMENTS #
#----------------#
args <- commandArgs( trailingOnly = TRUE )
scripts_dir <- args[1]

#-----------------------------------------------#
# LOAD PACKAGES, FUNCTIONS, AND SET ENVIRONMENT #
#-----------------------------------------------#
# Set wd to `scripts` directory
setwd( scripts_dir )
# Load the file with all the functions used throughout this script
source( file = "../../src/Functions.R" )
# Specify other paths
setwd( "../../01_timetree_inference/01_MCMCtree/" )
mcmc_dir <- paste( getwd(), "/", sep = "" )
setwd( scripts_dir )
setwd( "../" )
home_dir <- paste( getwd(), "/", sep = "" )
# Create dirs and log screen
if( ! dir.exists( paste( home_dir, "out_RData/", sep = "" ) ) ){
  dir.create( paste( home_dir, "out_RData/", sep = "" )  )
}
if( ! dir.exists( paste( home_dir, "plots/", sep = "" ) ) ){
  dir.create( paste( home_dir, "plots/", sep = "" )  )
}
outchecks_dir <- c( paste( home_dir, "plots/", sep = "" ) )
# Record a log file
if( ! dir.exists( paste( home_dir, "out_Rlogs/", sep = "" ) ) ){
  dir.create( paste( home_dir, "out_Rlogs/", sep = "" )  )
}
sink( paste( home_dir, "out_Rlogs/log_MCMCdiagn_posterior.txt",
             sep = "" ), append = FALSE, split = TRUE )
# By now, set the working directory to `home_dir`
setwd( home_dir )

#-------------------------------------------------------------#
# DEFINE GLOBAL VARIABLES -- modify according to your dataset #
#-------------------------------------------------------------#
# First, we will define the global variables that match the settings in our 
# analysis.

# 1. Number of chains
num_chains <- 6

# 2. Number of divergence times that have been estimated. One trick to find
# this out quickly is to subtract 1 to the number of species. In this case,
# there are 8 taxa (8), so the number of internal nodes
# is `n_taxa-=8-1=7`.
# Another way to verify this is by opening the `mcmc.txt` file and check the
# header. The first element after `Gen` will have the format of `t_nX`, where
# X will be an integer (i.e., 9). Subtract two to this number 
# (i.e., 9-2=7) and this will be your number of divergence times that are 
# parameters of the MCMC. Please modify the number below so it fits to the 
# dataset you are using. 
num_divt <- 7

# 3. Number of samples that you specified in the `MCMCtree` control file to 
# collect. NOTE: you may have not collect them all, but do not worry!
def_samples <- 20000

# 4. Quantile percentage that you want to set By default, the variable below is 
# set to 0.975 so the 97.5% and 2.5% quantiles (i.e., 95%CI). If you want to
# change this, however, just modify the value.
perc <- 0.975

# 5. Load a semicolon-separated file with info about calibrated nodes. Note that
# this file is output by script `Merge_node_labels.R`. A summary of its content
# in case you are to generate your own input files:
#
# Each column needs to be separated with semicolons and an extra blank line
# after the last row with calibration information needs to be added. If the
# extra blank is not added, R will complain and will not load the file!
# If you add a header, please make sure you name the column elements as 
# `Calib;node;Prior`. If not, the R function below will deal with the header,
# but make sure you set `head_avail = FALSE` when running `read_calib_f` 
# function below. An example of the content of this file is given below:
#
# ```
# Calib;node;Prior
# ex_n5;5;ST(5.8300,0.0590,0.1120,109.1240)
# ex_n7;7;B(4.1200,4.5200,0.0250,0.0250)
#
# ```
#
# The first column will have the name of the calibration/s that can help you
# identify which node belongs to which calibration. The second column is the
# number given to this node by`MCMCtree` (this information is automatically
# found when you run the script `Merge_node_labels.R`, otherwise you will need
# to keep checking the output file `node_trees.tree` to figure out which node
# is which). The third column is the calibration used for that node in
# `MCMCtree` format.
# 
# [[ NOTES ABOUT ALLOWED CALIBRATION FORMATS]]
#
# Soft-bound calibrations: 
#  E.g.1: A calibration with a minimum of 0.6 and a maximum of 0.8 would with  
#         the default tail probabilities would have the following equivalent 
#         formats:
#         >> B(0.6,0.8) | B(0.6,0.8,0.025,0.025)
#  E.g.2: A calibration with a minimum of 0.6 and a maximum of 0.8 would with  
#         the pL=0.001 and pU=0.025 would have the following format. Note that, 
#         whenever you want to modify either pL or pU, you need to write down 
#         the four  parameters in the format of "B(min,max,pL,pU)":
#         >> B(0.6,0.8,0.001,0.025)
#
# Lower-bound calibrations: 
#  E.g.1: A calibration with a minimum of 0.6 and the default parameters for
#         p = 0.1, c = 1, pL = 0.025:
#         >> L(0.6) | L(0.6,0.1,1,0.025)
#  E.g.2: A calibration with a hard minimum at 0.6, and so pL = 1e-300. 
#         Note that, whenever you want to modify either pL or pU, you need to  
#         write down the four parameters in the format of "L(min,p,c,pL)":
#         >> L(0.6,0.1,1,1e-300)
#
# Upper-bound calibrations: 
#  E.g.1: A calibration with a maximum of 0.8 and the default parameters for
#         pU = 0.025:
#         >> U(0.8) | U(0.8,0.025)
#  E.g.2: A calibration with a hard maximum at 0.8, and so pU = 1e-300. 
#         Note that, if you want to modify pU, you need to write down the two
#         parameters in the format of "U(max,pU)":
#         >> U(0.8,1e-300)
#
# ST distributions: 
#  The format accepted has four parameters: xi (location, mean root age), 
#  omega (scale), alpha (shape), nu (df). Accepted format: 
#  >> ST(5.8300,0.0590,0.1120,109.1240)
#
# SN distributions: 
#  The format accepted has three parameters: xi (location, mean root age), 
#  omega (scale), alpha (shape). Accepted format: 
#  >> SN(5.8300,0.0590,0.1120)  
#
#
# The next command executes the `read_calib_f` in-house function, which reads
# your input files (semicolon-separated files). The path to this directory is 
# what the argument `main_dir` needs. The argument `f_names` requires the name 
# of the file/s that you have used. Argument `dat` requires the same global 
# object that you have created at the beginning of the script.
dat    <- c( "cytb-123CP", "cytb-12CP", "cytb-12CP3CP" )
dat_ff <- list.files( path = "../00_inp_data/calibs/inp_calibs/",
                      pattern = "*csv",
                      full.names = FALSE )
##> CHECK
# If there was a `margVScalib` generated, do not use it! If not, this means
# that your `csv` file has already the required format to proceed
is_margcsv <- grep( pattern = "margVScalib", x = dat_ff )
if( length( is_margcsv ) > 0 ){
  dat_ff <- dat_ff[-is_margcsv]
}
##> END CHECK
# Get formatted calibration information
calib_nodes <- read_calib_f( main_dir = paste( "../00_inp_data/calibs/inp_calibs/",
                                               sep = "" ),
                             f_names = dat_ff,
                             dat = "cytb", head_avail = TRUE )

# 6. Number of columns in the `mcmc.txt` that are to be deleted as they do not 
# correspond to sample values for divergence times (i.e., the entries are not 
# names following the format `t_nX`). To figure out this number quickly, you 
# can open the `mcmc.txt` file, read the header, and count the number of `mu*`
# and `sigma2*` elements. Do not count the `lnL` value when looking at 
# `mcmc.txt` files generated when sampling from the posterior -- this is 
# automatically accounted for in the in-house R functions that you will 
# subsequently use. E.g., assuming an MCMC ran under a relaxed-clock model with  
# no partitions, we would see `mu` and `sigma2` columns. Therefore, the variable  
# would be set to `delcol_post <- 2`. Please modify the value/s below 
# (depending on having one or more datasets) according to the `mcmc.txt` file
# generated when sampling from the posterior (`delcol_posterior`).
delcol_post <- c( 2, 2,  # 123CP: GBM|ILN
                  2, 2,  # 12CP:  GBM|ILN
                  4, 4 ) # 12CP3CP: GBM|ILN
# --> When one alignment block, 2: `mu` and `sigma_2`
# --> When two alignment blocks, 4: `mu[1-2]`, `sigma2_[1-2]`

# 7. Path to the directory where the subdirectories where each chain ran for 
# each dataset are saved In this case, we will have the path to the directory 
# where the analyses when sampling from the prior took place (i.e., directory
# that contains the subdirectories from `1` to `n`, where `n` is the number
# of chains we ran).
all_paths <- vector( mode = "character", length = c( length( dat ) )*2 )
count <- 0
for( i in 1:c( length( dat ) ) ){
  count <- count + 1
  all_paths[count] <- paste( mcmc_dir, "01_posterior/GBM/",
                               i, "/", sep = "" )
  count <- count + 1
  all_paths[count] <- paste( mcmc_dir, "01_posterior/ILN/",
                               i, "/", sep = "" )
}

#--------------#
# ANALYSE DATA #
#--------------#
# Define object names
num_dirs      <- num_chains
delcol        <- delcol_post
path          <- all_paths
num_divt      <- num_divt
# The `sort` command will be useful if you have more than one dataset and
# you have ranked them alphabetically in your file structure going from
# `1`, `2`, `3`, etc.
dataset <- sort( c( paste( dat, "_GBM", sep = "" ),
                    paste( dat, "_ILN", sep = "" ) ) )
node_calib         <- vector( mode = "list", length = length( dataset ) )
names( node_calib) <- dataset
# Get only the matrix, not the list, hence the `[[1]]`
node_calib    <- calib_nodes[[ 1 ]]
perc          <- perc
def_samples   <- def_samples
prior         <- FALSE
out_dat       <- all_paths
time_unit     <- 100
out_file_pdf  <- sort( c( paste( "Convergence_plot_post_", dat, "_GBM",
                                 sep = "" ),
                          paste( "Convergence_plot_post_", dat, "_ILN",
                                 sep = "" ) ) )
out_title_pdf <- sort( c( paste( dat, "_GBM", sep = "" ),
                          paste( dat, "_ILN", sep = "" ) ) )
th            <- 0.1

##----------------------------------------------------------------------------##
cat( " - - - - - - - - - - - - - \n\n" )
cat( "[[ OPTIONS SPECIFIED ]]\n\n",
     "Number of chains: ", num_chains, "\n",
     "Number of divergence times estimated: ", num_divt, "\n",
     "Samples specified in the control file: ", def_samples, "\n",
     "Quantiles that will be calculated: [", 1-perc, "-", perc, "]\n",
     "Number of \"mu\" and \"sigma_2\" columns in \"mcmc.txt\" file: ", delcol_post, "\n",
     " |-->  One dataset for every two numbers; there are two",
     "relaxed clock models, GBM and ILN\n",
     "Paths:\n" )
all_paths
cat( "\n Data ID (one per dataset): ", dat, "\n",
     "Running from the prior?", prior, "\n",
     "Time unit: ", time_unit, "\n",
     "Threshold to check convergence in tails: ", th, "\n",
     "Flag for output files (one per dataset): ", out_title_pdf, "\n" )
cat( "\n[[ CALIBRATIONS ]] \n\n" )
node_calib
cat( "\n - - - - - - - - - - - - - \n" )

# Generate a list to keep all the returned objects
sum_post_QC          <- vector( "list", length( all_paths ) )
names( sum_post_QC ) <- dataset
# Now, run the `QC_conv` function in a loop
for( i in 1:length( dataset ) ){
  # NOTE: Only vectors with more than one element rely on `i`
  sum_post_QC[[ i ]] <- QC_conv( num_dirs = num_dirs, delcol = delcol[i], 
                                 path = path[i], num_divt = num_divt,
                                 # If you have more than one element in
                                 # list `node_calib`, amend the next
                                 # line accordingly!
                                 node_calib = node_calib,
                                 dataset = dataset[i],
                                 perc = perc, def_samples = def_samples,
                                 prior = prior, out_dat = out_dat[i],
                                 time_unit = time_unit, 
                                 out_file_pdf = out_file_pdf[i],
                                 out_title_pdf = out_title_pdf[i], 
                                 th = th,
                                 outchecks_dir = outchecks_dir )
}

# Save object!
cat( "\n ~> Saving RData object in case it needs to be inspected ... ..." )
if( ! dir.exists( paste( home_dir, "out_RData", sep = "" ) ) ){
  dir.create( paste( home_dir, "out_RData", sep = "" ) ) 
}
save( file = paste( home_dir, "out_RData/sum_post_QC.RData", sep = "" ),
      sum_post_QC )
cat( "\n ~> DONE! RData object saved as",
     paste( "\"",home_dir, "out_RData/sum_post_QC.Rdata\"", sep = "" ) )

cat( "\n\n ~> All the plots have been saved in directory ",
     paste( "\"", home_dir, "plots/ESS_and_chains_convergence/\"", sep = "" ) )
cat( "\n ~> All tables with sum stats have been saved in directory ",
     paste( "\"", home_dir, "out_RData/\"", sep = "" )  )
cat( "\n ~> A log file with the screen output has also been saved as",
     paste( "\"",home_dir, "out_Rlogs/log_MCMCdiagn_posterior.txt\"", sep = "" ), 
     "\n\n" )

