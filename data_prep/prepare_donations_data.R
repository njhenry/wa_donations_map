## #############################################################################
## 
## Script: Prepare donations and spatial data for mapping
## 
## Author: Nat Henry, github: @njhenry
## Created: 8 October 2020
## 
## Purpose: Data loading and preparation for map of WA 2020 election donations
## 
## #############################################################################

rm(list=ls())

## Setup: load libraries, functions, and settings ------------------------------

# Load libraries
require_packages <- c('argparse', 'data.table', 'glue', 'urltools', 'yaml')
# install.packages(require_packages)
dummy <- lapply(require_packages, library, character.only = TRUE)

# Load input arguments
parser <- argparse::ArgumentParser()
parser$add_argument('-r', '--repository', type='character', help='Repository filepath')
parser$add_argument('-v', '--version', type='character', help='Data prep version')
args <- parser$parse_args(TRUE)

# Load config file
CONFIG <- yaml::read_yaml(file.path(args$repository, 'config.yaml'))

# Load functions
source(file.path(args$repository, 'data_prep/data_prep_functions.R'))

# Create versioned output folder
output_dir_list <- create_output_folders(
  output_dir_base = CONFIG$output_dir_base,
  data_version = args$version
)
data_prep_dir <- output_dir_list$data_prep_dir
map_dir <- output_dir_list$map_dir

# Check to see if an API access token exists, and optionally read it
api_token_file <- file.path(args$repository, CONFIG$filenames$pdc_api_token)
api_token <- NULL
if(file.exists(api_token_file)) api_token <- readLines(api_token_file)

## Data loading ----------------------------------------------------------------

# Load and prepare donations data
donations_prepped <- load_prepare_donations_data(
  api_base_url = CONFIG$urls$donations_api,
  api_params = CONFIG$urls$donations_api_params,
  api_token = api_token,
  raw_data_filepath = file.path(data_prep_dir, CONFIG$filenames$donations_raw),
  prepped_data_filepath = file.path(data_prep_dir, CONFIG$filenames$donations_prepped)
)

# Load population data
# TODO

# Load shapefiles: census tracts, ZIP codes, leg. districts, counties
# TODO

## 

