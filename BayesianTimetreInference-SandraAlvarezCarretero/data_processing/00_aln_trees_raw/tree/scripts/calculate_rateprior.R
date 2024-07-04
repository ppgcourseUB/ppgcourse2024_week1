#-------------------#
# CLEAN ENVIRONMENT #
#-------------------#
rm( list = ls( ) )

#-----------------------#
# SET WORKING DIRECTORY #
#-----------------------#
library( rstudioapi ) 
# Get the path to current open R script and find main dir "00_Gene_filtering"
path_to_file <- getActiveDocumentContext()$path
script_wd <- paste( dirname( path_to_file ), "/", sep = "" )
wd <- gsub( pattern = "/scripts", replacement = "", x = script_wd )
setwd( wd )

#--------------#
# LOAD OBJECTS #
#--------------#
# Load tree 
raw_tt <- ape::read.tree( file = "cytb_rooted_bl.tree" )

#-------#
# TASKS #
#-------#
# 1. Find tree height. You can use the function `phytools::nodeHeights` to
#    calculate all the heights of the tree. Then, we can extract the maximum
#    height calculated, which will correspond to the length from the root to 
#    the highest tip.
tree_height <- max( phytools::nodeHeights( raw_tt ) ) # 0.3801525

# 2. Get the mean of the calibration set for the root to have the 
#    time for the speciation event at the root, what we will use 
#    to estimate the mean evolutionary rate later. We use a soft-bound
#    calibration to constraint the root age (i.e., a uniform
#    distribution with a minimum of 37.71 Ma and a 
#    maximum of 66.09 Ma with soft bounds). The average in time unit = 100 Ma 
#    is then 0.519 * 100 Ma.
root_age <- mean( c(0.3771,0.6609) ) # 0.519 * 100 Ma
# 3. Estimate mean rate based on the two different time units@
#    tree_height = mean_rate x root_age --> mean_rate = tree_height / root_age
mean_rate <- tree_height / root_age # 0.7324711 subst/site per time unit
# If we want to know the mean rate in subst/site/year, we apply the time unit.
# We should get the same estimate regardless the time unit used:
#
# Time unit 100 May (10^8y): 0.7324711 subst/site/10^8 = 7.32e-9 subst/site/y

# 4. Now, we can build the gamma distribution given that we now have an 
#    estimate for the mean rate. We will also use `alpha = 2` as we will start
#    with a vague distribution. Nevertheless, if you were very sure about the  
#    mean rate, you could build a more constraint prior.
#
#    mean_Gamma = mean_rate = alpha / beta --> beta = alpha / mean_rate
alpha <- 2
beta  <- alpha/mean_rate # 2.730483 ~ 2.7

# We can plot these distributions
curve( dgamma( x, shape = 2, rate = beta ), from = 0, to = 3, col = "black" )
legend( "topright", legend = c( "G(2,2.7) " ), 
        col = "black", lty = 1, box.lty = 2 )

# 5. Plot the gamma distribution
if ( ! dir.exists( "out_RData" ) ){
  dir.create( "out_RData" )
}
pdf( file = "out_RData/gamma_dists.pdf", paper = "a4" )
curve( dgamma( x, shape = 2, rate = beta ), from = 0, to = 8, col = "black" )
legend( "topright", legend = c( "G(2,2.7) " ), 
        col = "black", lty = 1, box.lty = 2 )
dev.off()

