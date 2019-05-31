# /////////////////////////////////////////////////////////////////////////
#
# Phylogenetic mixed effects meta-analyses with PL as the response variable and
# land use, levels of dependence on pollinators and their interaction as
# predictors.
#
# /////////////////////////////////////////////////////////////////////////


# Load packages
library(metafor)
library(ape)
library(multcomp)

# Cleans environment
rm(list = ls(all.names = TRUE))


# Read and prepare data ---------------------------------------------------

# Phylogeny from GloPL database:
# https://datadryad.org/resource/doi:10.5061/dryad.dt437
tree <- read.tree("./data/phylogenetic_tree.tre")
# Phylogenetic variance-covariance matrix
vcov <- ape::vcv(tree)

# Load data processed from GloPL database
load(file = "data/glopl_data.rda")

# PD species only
sub_pd <- dt[which(dt$pd == "PD"), ]
# Table only for vegetation land-use
sub_pd_no_urban <- subset(sub_pd, ! luh %in% 'LUH.urban')
sub_pd_no_urban <- droplevels(sub_pd_no_urban)
rm(sub_pd)


# Land-use x pollinator dependence ----------------------------------------

LUH.pd.lnr <- rma.mv(es ~ pd:luh - 1,
                     V = var_es,
                     random = list(~ 1|factors,
                                   ~ 1|species),
                     R = list(species = vcov),
                     data =  dt,
                     method = "ML")

summary(glht(LUH.pd.lnr,
             linfct = rbind(
               c(0, 1, 0, -1, 0, 0),
               c(0, 1, 0, 0, 0, -1),
               c(0, 0, 0, 1, 0, -1)),
             df = df.residual(LUH.pd.lnr)),
        test = adjusted("holm"))


# Land-use x Ecological specialization ------------------------------------

LUH.eco.lnr <- rma.mv(es ~ eco_spec:luh - 1,
                      V = var_es,
                      random = list(~ 1|factors,
                                    ~ 1|species),
                      R = list(species = vcov),
                      data = sub_pd_no_urban,
                      knha = TRUE,
                      method = "ML")

summary(glht(LUH.eco.lnr,
             linfct = rbind(c(1, 0, 0, -1, 0, 0),
                            c(0, 1, 0, 0, -1, 0),
                            c(0, 0, 1, 0, 0, -1)),
             df = df.residual(LUH.eco.lnr)),
        test = adjusted("holm"))


# Land-use x functional specialisation ------------------------------------

LUH.fun.lnr <- rma.mv(es ~ fun_spec:luh - 1,
                      V = var_es,
                      random = list(~ 1|factors,
                                    ~ 1|species),
                      R = list(species = vcov),
                      data = sub_pd_no_urban,
                      method = "ML")

summary(glht(LUH.fun.lnr,
             linfct = rbind(c(1, 0, 0, -1, 0, 0),
                            c(0, 1, 0, 0, -1, 0),
                            c(0, 0, 1, 0, 0, -1)),
             df = df.residual(LUH.fun.lnr)),
        test = adjusted("holm"))
