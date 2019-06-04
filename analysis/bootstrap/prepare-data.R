# /////////////////////////////////////////////////////////////////////////
#
# Prepare data for bootstrapping the phylogenetic mixed effects models.
#
# /////////////////////////////////////////////////////////////////////////


# Load packages
library(data.table)
library(ape)

# Phylogeny from GloPL database:
# https://datadryad.org/resource/doi:10.5061/dryad.dt437
tree <- read.tree("./data/phylogenetic_tree.tre")
# Phylogenetic variance-covariance matrix
vcov <- ape::vcv(tree)

# Load data processed from GloPL database
load(file = "data/glopl_data.rda")
setDT(dt)


# Data for model Land-use x pollinator dependence  ------------------------

d_pdaf <- dt[!is.na(luh)] # eliminate any NA-s from luh column
d_pdaf <- droplevels(d_pdaf)


# Data for model Land-use x Ecological specialization ---------------------

# Select "PD" species only, remove urban cases ("LUH.urban") and any NA-s from
# the luh and eco_spec columns.
d_eco_spec <- dt[pd == "PD"][!luh %in% "LUH.urban"][!is.na(luh)][!is.na(eco_spec)]
d_eco_spec <- droplevels(d_eco_spec)


# Data for model Land-use x functional specialisation ---------------------

d_fun_spec <- dt[pd == "PD"][!luh %in% "LUH.urban"][!is.na(luh)][!is.na(fun_spec)]
d_fun_spec <- droplevels(d_fun_spec)

save(vcov, d_pdaf, d_eco_spec, d_fun_spec, file = "./data/data_for_bootstrap.rda")
