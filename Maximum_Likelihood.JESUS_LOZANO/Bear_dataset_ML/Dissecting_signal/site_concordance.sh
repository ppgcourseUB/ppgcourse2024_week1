#!/bin/sh

iqtree -t ../ultrafast_bootstrap/50_genes.fa.treefile -s 50_genes.fa -m MODEL --scfl 100 --prefix site_concordance -nt 8
