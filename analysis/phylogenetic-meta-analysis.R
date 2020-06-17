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

# Model for the results reported in Table S2
LUH.pd.lnr <- rma.mv(es ~ pd:luh - 1,
                     V = var_es,
                     random = list(~ 1|factors,
                                   ~ 1|species),
                     R = list(species = vcov),
                     data =  dt,
                     method = "ML")
summary(LUH.pd.lnr) # Test of Moderators QM reported in Table S2
# Contrast values reported in Table S2
summary(glht(LUH.pd.lnr,
             linfct = rbind(
               c(0, 1, 0, -1, 0, 0),
               c(0, 1, 0, 0, 0, -1),
               c(0, 0, 0, 1, 0, -1)),
             df = df.residual(LUH.pd.lnr)),
        test = adjusted("holm"))


# Model for the results reported in Table S7
dt$id <- 1:nrow(dt)
LUH.pd.lnr.2 <- rma.mv(es ~ pd + luh + pd * luh,
                       V = var_es,
                       random = list(~ 1|factors,
                                     ~ 1|species,
                                     ~ 1|id),
                       R = list(species = vcov),
                       data = dt,
                       method = "ML")
# Values reported in Table S7
summary(LUH.pd.lnr.2)


# Model for the results reported in Table S6
LUH.pd.lnr.3 <- rma.mv(es ~ pd + luh + pd * luh,
                       V = var_es,
                       random = list(~ 1|factors,
                                     ~ 1|species),
                       R = list(species = vcov),
                       data = dt,
                       method = "ML")
# Values reported in Table S6
summary(LUH.pd.lnr.3)


# Land-use x Ecological specialization ------------------------------------

LUH.eco.lnr <- rma.mv(es ~ eco_spec:luh - 1,
                      V = var_es,
                      random = list(~ 1|factors,
                                    ~ 1|species),
                      R = list(species = vcov),
                      data = sub_pd_no_urban,
                      knha = TRUE,
                      method = "ML")
summary(LUH.eco.lnr)


# Model for the results reported in Table S9
sub_pd_no_urban$id <- 1:nrow(sub_pd_no_urban)
LUH.eco.lnr.2 <- rma.mv(es ~ eco_spec + luh + eco_spec * luh, 
                        V = var_es,
                        random = list(~ 1|factors,
                                      ~ 1|species,
                                      ~ 1|id),
                        R = list(species = vcov),
                        data = sub_pd_no_urban,
                        knha = TRUE,
                        method = "ML")
# Values reported in Table S9
summary(LUH.eco.lnr.2)


# Model for the results reported in Table S8
LUH.eco.lnr.3 <- rma.mv(es ~ eco_spec + luh + eco_spec * luh, 
                        V = var_es,
                        random = list(~ 1|factors,
                                      ~ 1|species),
                        R = list(species = vcov),
                        data = sub_pd_no_urban,
                        knha = TRUE,
                        method = "ML")
# Values reported in Table S8
summary(LUH.eco.lnr.3)


# Land-use x functional specialisation ------------------------------------

# Model for the results reported in Table S5
LUH.fun.lnr <- rma.mv(es ~ fun_spec:luh - 1,
                      V = var_es,
                      random = list(~ 1|factors,
                                    ~ 1|species),
                      R = list(species = vcov),
                      data = sub_pd_no_urban,
                      method = "ML")
summary(LUH.fun.lnr) # Test of Moderators QM reported in Table S5

# Contrast values reported in Table S5
summary(glht(LUH.fun.lnr,
             linfct = rbind(c(1, 0, 0, -1, 0, 0),
                            c(0, 1, 0, 0, -1, 0),
                            c(0, 0, 1, 0, 0, -1)),
             df = df.residual(LUH.fun.lnr)),
        test = adjusted("holm"))


# Changing the order of levels for convenience of contrasts displayed in summary
sub_pd_no_urban$fun_spec_2 <- factor(sub_pd_no_urban$fun_spec,
                                     levels = c("other_specialized", "bee_specialized", "generalist"))
sub_pd_no_urban$luh_2 <- factor(sub_pd_no_urban$luh, levels = c("LUH.veget", "LUH.managed"))

# Model for the results reported in Table S11
LUH.fun.lnr.2 <- rma.mv(es ~ luh_2 + fun_spec_2 + luh_2 * fun_spec_2, 
                        V = var_es,
                        random = list(~ 1|factors,
                                      ~ 1|species,
                                      ~ 1|id),
                        R = list(species = vcov),
                        data = sub_pd_no_urban,
                        knha = TRUE,
                        method = "ML")
# Values reported in Table S11
summary(LUH.fun.lnr.2)


# Model for the results reported in Table S10
LUH.fun.lnr.3 <- rma.mv(es ~ luh_2 + fun_spec_2 + luh_2 * fun_spec_2, 
                        V = var_es,
                        random = list(~ 1|factors,
                                      ~ 1|species),
                        R = list(species = vcov),
                        data = sub_pd_no_urban,
                        knha = TRUE,
                        method = "ML")
# Values reported in Table S10
summary(LUH.fun.lnr.3)


# Save model objects
save(list = ls(pattern = "LUH."), file = "analysis/models.RData", compression_level = 9)
