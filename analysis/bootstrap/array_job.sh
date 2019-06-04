#!/bin/bash
#$ -S /bin/bash
#$ -N bootstrap_land_use_models_glopl
#$ -l h_rt=1:00:00
#$ -l h_vmem=2G
#$ -cwd
#$ -o /work/$USER/$JOB_NAME-$JOB_ID/log-files/$JOB_NAME-$JOB_ID-$TASK_ID.log
#$ -j y
#$ -binding linear:1

## Bash script that executes the R script (bootstrap-models.R) on each available 
## CPU of the cluster.
## Requested 1 h of running time per CPU, but the models should take approx. 
## 30 min per CPU.

module load R/3.5.1-1

data_path=$1
output=/work/$USER/$JOB_NAME-$JOB_ID
mkdir -p $output

Rscript bootstrap-models.R \
  "$data_path" \
  "$output/coef-$SGE_TASK_ID.rda"
