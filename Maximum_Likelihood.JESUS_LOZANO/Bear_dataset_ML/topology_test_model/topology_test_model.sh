#!/bin/sh

iqtree -s 50_genes.fa -z ../bear_species_trees_topologies.tre -m LG+C20+F+G -redo
