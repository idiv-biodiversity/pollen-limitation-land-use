`phylogenetic-meta-analysis.R` - phylogenetic mixed effects meta-analyses with PL as the response variable and land use, levels of dependence on pollinators and their interaction as predictors.

In the `bootstrap` folder:

- `array_job.sh`: Bash script that executes the R script `bootstrap-models.R` on each available CPU of a local UFZ cluster. The bash script was submitted from a terminal to the Univa Grid Engine cluster with a `qsub` command, e.g.: `qsub -t 1-520 array_job.sh /path/to/data_for_bootstrap.rda`. We purposely used more than 500 bootstraps/jobs (520) because some can fail.
- `bootstrap-models.R`: R script for bootstrapping the phylogenetic mixed effects models. Works only together with `array_job.sh`.
- `prepare-data.R`: R script that produced the data needed for bootstrapping, stored in `./data/data_for_bootstrap.rda`.
- `get-bootstrap-coeff.R`: R script to extract the bootstrap coefficients from the binary files obtained after running the array job on the cluster.
