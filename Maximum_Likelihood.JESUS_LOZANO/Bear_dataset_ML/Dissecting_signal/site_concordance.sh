#!/bin/sh

iqtree -t PREVIOUS_TREE -s 50_genes.fa -m MODEL --scfl 100 --prefix site_concordance -nt 8
