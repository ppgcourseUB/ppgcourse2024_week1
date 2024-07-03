#!/bin/sh

iqtree -s 50_genes.fa -m MODEL -b 5 -nt 8 -redo
