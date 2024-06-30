#!/bin/sh

iqtree -s 50_genes.fa -m LG+C20+F+G -b 10 -nt 8 -redo
