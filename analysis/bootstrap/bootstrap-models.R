# /////////////////////////////////////////////////////////////////////////
#
# This R script was executed by a job scheduler on a local UFZ Linux cluster via
# the shell script array_job.sh
#
# /////////////////////////////////////////////////////////////////////////


# Optparse section --------------------------------------------------------

library(optparse)

# Defaults

default.verbose <- FALSE

# Parsing arguments

options <- list(
  make_option(opt_str = c("-v", "--verbose"),
              action  = "store_true",
              default = default.verbose,
              help    = "Print more output on what's happening")
)

parser <- OptionParser(usage       = "Rscript %prog [options] data_path output",
                       option_list = options,
                       description = "\nan",
                       epilogue    = "With support from Christian Krause")

cli <- parse_args(parser, positional_arguments = 2)


# Assign shortcuts

verbose   <- cli$options$verbose
data_path <- cli$args[1]
output    <- cli$args[2]


# The R-job section -------------------------------------------------------

# Set option for Random Number Generation. Needed for back compatibility with
# versions of R before 3.6.0. See https://stackoverflow.com/a/56381613/5193830
RNGkind(sample.kind = "Rounding")

library(metafor)
library(data.table)

# Load data objects for models
load(file = data_path)


# Sample with replacement the data tables

# The task id from the scheduler becomes the seed:
task_id <- Sys.getenv("SGE_TASK_ID")
# Print in the log file each seed
print(paste0("Random Number Generation using: set.seed(", task_id, ")"))

set.seed(task_id)
d_pdaf_sample <- d_pdaf[, .SD[sample(.N, replace = TRUE)], by = .(luh, pd)]

set.seed(task_id)
d_eco_spec_sample <- d_eco_spec[, .SD[sample(.N, replace = TRUE)], by = .(luh, eco_spec)]

set.seed(task_id)
d_fun_spec_sample <- d_fun_spec[, .SD[sample(.N, replace = TRUE)], by = .(luh, fun_spec)]


# Models

random_factors <- list(~ 1|factors,
                       ~ 1|species)


# Land-use x pollinator dependence
try({
  LUH.pd.lnr <- rma.mv(es ~ pd:luh - 1,
                       V = var_es,
                       random = random_factors,
                       R = list(species = vcov),
                       data =  d_pdaf_sample,
                       method = "ML")
})

# Land-use x Ecological specialization
try({
  LUH.eco.lnr <- rma.mv(es ~ eco_spec:luh - 1,
                        V = var_es,
                        random = random_factors,
                        R = list(species = vcov),
                        data = d_eco_spec_sample,
                        method = "ML")
})

# Land-use x Functional specialization
try({
  LUH.fun.lnr <- rma.mv(es ~ fun_spec:luh - 1,
                        V = var_es,
                        random = random_factors,
                        R = list(species = vcov),
                        data = d_fun_spec_sample,
                        method = "ML")
})


# Save model coefficients to the given "output" path that will be provided
# automatically via the .sh script when submitting the array job in the terminal

coef_boot <- list(LUH.pd.lnr  = try( LUH.pd.lnr[["beta"]] ),
                  LUH.eco.lnr = try( LUH.eco.lnr[["beta"]] ),
                  LUH.fun.lnr = try( LUH.fun.lnr[["beta"]] ))

save(coef_boot, file = output)
