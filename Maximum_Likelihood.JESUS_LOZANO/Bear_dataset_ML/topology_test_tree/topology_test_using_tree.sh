#!/bin/sh

iqtree -s 50_genes.fa -z ../bear_species_trees_topologies.tre -m MODEL -te ../ultrafast_bootstrap/50_genes.fa.treefile -zb 1000 -zw -au nt 8 -redo
