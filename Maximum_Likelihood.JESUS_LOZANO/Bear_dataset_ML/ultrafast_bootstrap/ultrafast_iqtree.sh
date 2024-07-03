#!/bin/sh

iqtree -s 50_genes.fa -m MODEL -bb 1000 -nt 8 -redo
