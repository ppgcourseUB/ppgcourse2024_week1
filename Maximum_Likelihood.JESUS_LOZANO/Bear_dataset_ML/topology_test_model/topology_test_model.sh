#!/bin/sh

iqtree -s 50_genes.fa -z ../bear_species_trees_topologies.tre -m MODEL -zb 1000 -zw -au nt 8 -redo
