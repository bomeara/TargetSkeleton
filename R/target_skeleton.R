#' Create target skeleton directory
#' 
#' This creates necessary target files and templates in the current directory. You can optionally set a different directory (such as a Dropbox folder) to hold the _targets directory.
#' @param include_examples If TRUE, includes some example commands in files
#' @param store_path If set, tells targets to use the specified directory for its _targets objects
#' @export 

target_skeleton <- function(include_examples=TRUE, store_path=NULL) {
	dir.create("R")
	dir.create("results")
	dir.create("data")
	if (!is.null(store_path)) {
		targets::tar_config_set(store = store_path)
	}
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

ncores_to_allocate <- 2 # change to 1 to avoid multicore; increase if your computer has capacity

tar_option_set(
	packages = c(
		"dplyr",
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
	tar_target(loaded_file, file_read(input_file)),
	tar_target(means, c(0, 1, 10)),
	tar_target(sds, c(0.2, 0.5)),
	tar_target(reps, 100),
	tar_target(
		name = sim_result,
		command = simulation_start(
			means,
			sds,
			reps
		),
		pattern = cross(
			means,
			sds,
			reps
		)
	),
	tar_target(output_plot, simulation_plot(sim_result)),
	tar_render(report, "report.qmd", output_file="results/report.pdf"),
	tar_target(saved_results, results_save(sim_result), format="file")
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
		cat(
			'
file_read <- function(input_name) {
	result <- read.csv(input_name)
	result_desired <- result[result$number>0,] # as an example of filtering
	return(result_desired)
}

simulation_start <- function(m, s, r) {
	samples <- stats::rnorm(n = r, mean = m, sd = s)
	result <- data.frame(mean = m, sd = s, nrep = r, lowest = min(samples), highest = max(samples))
	return(result)
}

simulation_plot <- function(sim_result) {
	sim_result$mean <- as.factor(sim_result$mean)
	g <- ggplot(sim_result, aes(x=sd, y=highest, group=mean, colour=mean)) + geom_line() + geom_point() + theme_minimal()
	return(g)
}

results_save <- function(sim_result) {
	write.csv(sim_result, file="results/sim_result.csv")
	return("results/sim_result.csv")
}


		',
			file = "R/functions.R"
		)
	} else {
		cat("", file="R/functions.R")
	}
	
	if(include_examples) {
		cat(
			'---
title: "Splendid report"
author: "Mary Anning"
date: last-modified
date-format: "DD-MMM-YYYY"
format:
  pdf:
    fig-width: 8
    fig-height: 5
    code-fold: true
---


```{r, echo=FALSE}
library(targets)

tar_load(reps)
tar_load(output_plot)
tar_load(sim_result)

source("R/functions.R")

```


# Big headline

We can use standard markdown for formatting. 

## Smaller headline

We can include short R expressions inline by doing backtick with R; for example, this ran with `r reps` replicates per set of conditions.

We can also include plots:

```{r}
#| echo: false
#| warnings: false
print(output_plot)
```

And tables:

```{r}
#| echo: false
knitr::kable(sim_result)
```
',
			file = "report.qmd"
		)	
	}
	
}