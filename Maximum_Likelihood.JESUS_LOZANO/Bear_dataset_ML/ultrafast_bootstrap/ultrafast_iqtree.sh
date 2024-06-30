#!/bin/sh

iqtree -s 50_genes.fa -m LG+C20+F+G -bb 1000 -nt 8 -redo
