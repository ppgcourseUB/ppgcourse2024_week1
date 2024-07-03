#!/bin/sh

iqtree -s 50_genes.fa -m MF -mset LG+F+G,WAG+F+G,JTT+F+G -madd LG+C20+F+G,LG+C10+F+G,LG4X --score-diff all -nt 8 -redo
