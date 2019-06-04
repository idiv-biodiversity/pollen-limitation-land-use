`phylogenetic-meta-analysis.R` - phylogenetic mixed effects meta-analyses with PL as the response variable and land use, levels of dependence on pollinators and their interaction as predictors.

In the `bootstrap` folder:

- `array_job.sh`: Bash script that executes the R script `bootstrap-models.R` on each available CPU of a local UFZ cluster.
- `bootstrap-models.R`: R script for bootstrapping the phylogenetic mixed effects models. Works only together with `array_job.sh`.
- `prepare-data.R`: R script that produced the data needed for bootstrapping, stored in `./data/data_for_bootstrap.rda`.
