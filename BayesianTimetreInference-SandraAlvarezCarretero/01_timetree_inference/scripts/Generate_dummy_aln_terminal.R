#!/usr/bin/env Rscript

#----------------#
# LOAD ARGUMENTS #
#----------------#
args <- commandArgs( trailingOnly = TRUE )
scripts_dir <- args[1]

#-----------------------------------------------#
# LOAD PACKAGES, FUNCTIONS, AND SET ENVIRONMENT #
#-----------------------------------------------#
# Set working directory to one dir up
wd <- gsub( pattern = "/scripts", replacement = "", x = scripts_dir )
# Set working directory
setwd( wd )

#--------------#
# LOAD OBJECTS #
#--------------#
# The tips in the uncalibrated tree will be used to generate the dummy
# alignments
tt <- ape::read.tree( file = "../00_inp_data/cytb_uncalib.tree" )

##----------------------------------------------------------------------------##
cat( "\n - - - - - - - - - - - - - \n\n" )
cat( "[[ OPTIONS SPECIFIED ]]\n\n",
     "~> Working directory: \n",
     paste( "    \"" , wd, "\"", sep = "" ),
     "\n ~> Uncalibrated tree file (rel location to wd): \n",
     "    \"../00_inp_data/cytb_uncalib.tree\"\n",
     "~> Output directory (rel location to wd): \n",
     "    \"dummy_aln/dummy_aln.aln\"\n" )
cat( "\n - - - - - - - - - - - - - \n\n" )

##----------------------------------------------------------------------------##

#-------#
# TASKS #
#-------#
# 1. Find number of taxa 
num_sp        <- length( tt$tip.label )
spnames       <- tt$tip.label
phylip_header <- paste( num_sp, "  1", sep = "" )

phylip_header_aln <- paste( num_sp, "  2\n", sep = "" )
spnames_2chars      <- paste( spnames, "     AT", sep = "" )

# 2. Generate dummy aln
if( ! dir.exists( "dummy_aln/" ) ){
  dir.create( "dummy_aln/" )
}
num_parts <- 1
for( i in 1:num_parts ){
  if( i == 1 ){
    write( x = phylip_header_aln, file = paste( "dummy_aln/dummy_aln.aln",
                                                sep = "" ) )
    write( x = spnames_2chars, file = paste( "dummy_aln/dummy_aln.aln",
                                             sep = "" ),
           append = TRUE )
  }else{
    write( x = paste( "\n", phylip_header_aln, sep = "" ),
           file = paste( "dummy_aln/dummy_aln.aln", sep = "" ),
           append = TRUE )
    write( x = spnames_2chars, file = paste( "dummy_aln/dummy_aln.aln",
                                             sep = "" ),
           append = TRUE )
  }
  
}


