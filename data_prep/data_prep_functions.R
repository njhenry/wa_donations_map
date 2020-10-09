## #############################################################################
## 
## Data preparation functions for WA donations map
## 
## Author: Nat Henry, github: @njhenry
## Created: 8 October 2020
## 
## Purpose: Functions for loading and preparing data for the WA donations map
## 
## #############################################################################


#' @title Create output folders
#' 
#' @description Create versioned output folder. The versioned folder will be 
#'   located within a known base directory, and will itself contain two
#'   sub-folders:
#'     - '<versioned dir>/data_prep', for data preparation
#'     - '<versioned dir>/map', which contains the final data that will be used
#'       for the website
#' 
#' @param output_dir_base [char] Base output directory. A versioned directory
#'   will be created within this directory
#' @param data_version [char] The versioned directory that will be created 
#'   within the main output directory.
#' 
#' @return List with three items:
#'   - 'output_dir': Path to the top level of the versioned output directory
#'   - 'data_prep_dir': Path to the data prep subdirectory
#'   - 'map_dir': Path to the mapping data subdirectory
#'   
#' @export
create_output_folders <- function(output_dir_base, data_version){
  # Set up directory names
  output_dir <- file.path(output_dir_base, data_version)
  dir_list <- list(
    output_dir = output_dir,
    data_prep_dir = file.path(output_dir, 'data_prep'),
    map_dir = file.path(output_dir, 'map')
  )
  # Create directories
  dummy <- lapply(
    dir_list,
    function(dd) dir.create(dd, recursive = TRUE, showWarnings = FALSE)
  )
  # Return output directories
  return(dir_list)
}


#' @title Build GET query
#' 
#' @description Given a base URL and a set of parameters for a GET query, build
#'   the full URL
#' 
#' @param base_url [char] Base URL on which to append additional arguments
#' @param args [list] Named list of character vectors: List names correspond to
#'   fields and list values correspond to the arguments passed to those fields
#' @api_token [char, default NULL] API access token (may prevent throttling)
#' 
#' @import glue urltools
#' @export
build_GET_query <- function(base_url, args, api_token = NULL){
  query_url <- base_url
  if(length(args) > 0){
    # Collapse all arguments
    args_collapsed <- Reduce(
      f = function(x, y) glue::glue("{x}&{y}"),
      x = lapply(
        X = 1:length(args), 
        FUN = function(ii) glue::glue("{ names(args)[ii] }={ args[[ii]] }")
      )
    )
    # Paste onto the end of the url
    query_url <- glue::glue('{query_url}?{args_collapsed}')
  }
  # Optionally add an API access token
  if(!is.null(api_token)){
    url_suffix <- ifelse(length(args)==0, '?', '&')
    query_url <- glue::glue('{query_url}{url_suffix}$$app_token={api_token}')
  }
  return(query_url)
}


#' @title Save raw donations data to file
#' 
#' @description Given the API URL to download donations data in CSV format, 
#'   arguments for the API, and an output filepath to save to, download raw 
#'   donations data to that filepath.
#'   
#' @param api_base_url [char] Base URL on which to append additional arguments.
#'   This function expects the API to return a CSV-formatted file
#' @param api_params [list] Named list of character vectors: List names 
#'   correspond to API fields and list values correspond to the arguments passed
#'   to those fields
#' @api_token [char] API access token (may prevent throttling)
#' @param raw_data_filepath [char] Filepath to save raw data to. Assumes that 
#'   the containing folder already exists
#' 
#' @return Raw donations data, as a data.table (also saves to file)
#' 
#' @import data.table glue
#' @export
load_save_donations_raw <- function(
  api_base_url, api_params, api_token, raw_data_filepath
){
  # Build API query
  api_query <- build_GET_query(
    base_url = api_base_url,
    args = api_params,
    api_token = api_token
  )
  # Save file to path
  if(file.exists(raw_data_filepath)) file.remove(raw_data_filepath)
  utils::download.file(url=api_query, destfile=raw_data_filepath, quiet=TRUE)
  # Load CSV file as data.table
  donations_dt <- data.table::fread(raw_data_filepath)
  return(donations_dt)
}



#' @title Prepare WA donations data
#' 
#' @description Given a data.table of raw donations data, prepare the table for
#'   use in the donations map
#' 
#' @param donations_data_raw Raw data.table of donations
#' @param prepped_data_filepath Filepath where prepared donations data will be
#'   saved
#' 
#' @return Prepared data.table of donations data
#' 
#' @import data.table
#' @export
prepare_save_donations_data <- function(donations_data_raw, prepped_data_filepath){
  # Prepare data
  # TODO
  donations_data_prepared <- data.table::copy(donations_data_raw)
  # Save to file
  data.table::fwrite(donations_data_prepared, file=prepped_data_filepath)
  return(donations_data_prepared)
}


#' @title Load and prepare donations data
#' 
#' @description Wrapper script to load and prepare donations data from the 
#'   Washington Public Disclosure Commission.
#'
#' @param api_base_url [char] URL for the Public Disclosure Commission API
#' @param api_params [list] Named list of character vectors: List names 
#'   correspond to PDC API fields and list values correspond to the arguments 
#'   passed to those fields
#' @api_token [char] API access token (may prevent throttling)
#' @param raw_data_filepath [char] Filepath where raw donations data will be
#'   saved
#' @param prepped_data_filepath Filepath where prepared donations data will be
#'   saved
#' 
#' @return Data.table of prepared donations data. Functions wrapped by this 
#'   function also save CSVs of the raw and prepared donations data to the 
#'   specified paths
#' 
#' @export
load_prepare_donations_data <- function(
  api_base_url, api_params, api_token, raw_data_filepath, prepped_data_filepath
){
  # Load and save raw donations data
  donations_data_raw <- load_save_donations_raw(
    api_base_url = api_base_url,
    api_params = api_params,
    api_token = api_token,
    raw_data_filepath = raw_data_filepath
  )
  # Prepare and save donations data
  donations_data_prepared <- prepare_save_donations_data(
    donations_data_raw = donations_data_raw,
    prepped_data_filepath = prepped_data_filepath
  )
  return(donations_data_prepared)
}
