#' Create target skeleton directory
#' 
#' This creates necessary target files and templates in the current directory. You can optionally set a different directory (such as a dropbox folder) to hold the _targets directory.
#' @param scratch_path If set, tells targets to use the specified directory for its _targets objects
#' @param include_examples If TRUE, includes some example commands in files
#' @export 

target_skeleton <- function(scratch_path="", include_examples=TRUE) {
	dir.create("R")
	dir.create("results")
	dir.create("data")
	cat(
		'
source("_targets.R")
tar_make()
tar_load(everything(), strict=FALSE) # If you are creating something with large objects where you do not want everything in memory, comment this out',
		file="run.R"
	)
	cat(
		'
library(targets)
library(tarchetypes)
library(crew)
ncores_to_allocate <- 2
tar_option_set(
	packages = c(
		"dplyr",
		"phylogram",
		"ggplot2",
		"cowplot",
		"stats"
	),
	controller = crew_controller_local(workers = ncores_to_allocate) 
)
		
source("R/functions.R")
		
		',
		file = "_targets.R"
	)
	
	if(include_examples) {
		cat(
'list(
	tar_target(input_file, command = "data/input.csv", format="file"),
	tar_target(loaded_file, read_file(input_file)),
	tar_target(means, c(0, 1, 10)),
	tar_target(sds, c(0.2, 0.5)),
	tar_target(reps, 100)),
	tar_target(
		name = sim_result,
		command = doRun(
			means,
			sds,
			reps
		),
		pattern = cross(
			means,
			sds,
			reps
		)
	)
)',
			file = "_targets.R",
			append = TRUE
		)		
	} else {
		cat(
'list()
			',
			file = "_targets.R",
			append=TRUE
		)		
	}
	
	if(include_examples) {
		fake_data <- data.frame(letter = LETTERS[1:10], number = c(1:9, -99), bool = rep(c(TRUE, FALSE),5))
		write.csv(fake_data, file="data/input.csv", row.names=FALSE)
	}
	
	if(include_examples) {
		cat('
read_file <- function(input_name) {
	result <- read.csv(input_name)
	result_desired <- result[result$number>0,] # as an example of filtering
	return(result_desired)
}

doRun <- function(m, s, r) {
	samples <- stats::rnorm(n = r, mean = m, sd = s)
	result <- data.frame(mean = m, sd = s, nrep = r, lowest = min(samples), highest = max(samples))
	return(result)
}
		',
			file = "R/functions.R"
		)
	} else {
		cat("", file="R/functions.R")
	}
	
}