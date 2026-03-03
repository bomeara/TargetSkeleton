# TargetSkeleton

This package creates a sample, simple [targets](https://books.ropensci.org/targets/) workflow. Create the directory where you want your workflow to run, then

```
library(TargetSkeleton)
target_skeleton()
```

to create a sample `R/functions.R` file, a `targets.R` file, a sample quarto report, and a `run.R` file that will start a workflow if you call `source('run.R')`, including saving a csv file and a quarto report in a new `results` directory. The goal of this is to make it easier to quick start `targets` runs. Some options:

* The argument `include_examples=FALSE` will create the overall structure but without the sample files
* Passing in a path for `store_path` will call `targets::tar_config_set()` to store intermediate results in the specified path. This can be helpful if the overall workflow (functions, input and output files, etc.) are going to be in git but you don't want to use git (or git lfs) to handle the intermediate files in the `_targets` directory. For example, I sometimes use a dropbox directory for storing the `_targets` directory so that a colleague and I can have a synchronized `_targets` dir without the hassle of managing all the intermediate results with git.

## Install

```
install.packages("remotes")
remotes::install_github("bomeara/TargetSkeleton")
```

