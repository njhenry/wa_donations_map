## #############################################################################
## 
## Prepare donations and spatial data for mapping
## 
## Author: Nat Henry, njhenry
## Created: 8 October 2020
## 
## Purpose: Data loading and preparation for map of WA 2020 election donations
## 
## #############################################################################

rm(list=ls())

## Setup: load libraries, functions, and settings ------------------------------

library(argparse)
library(data.table)
library(yaml)

