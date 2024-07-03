#!/bin/sh

iqtree -s 50_genes.fa -z ../bear_species_trees_topologies.tre -te ../ultrafast_bootstrap/50_genes.fa.treefile -nt 8 -redo
