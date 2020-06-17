# /////////////////////////////////////////////////////////////////////////
#
# Extract the bootstrap coefficients from the binary files obtained after
# running the array job on the cluster. It also computes the mean, standard
# deviation, standard error and the confidence interval limits for each
# coefficient.
#
# /////////////////////////////////////////////////////////////////////////

# Set option for Random Number Generation. Needed for back compatibility with
# versions of R before 3.6.0. See https://stackoverflow.com/a/56381613/5193830
RNGkind(sample.kind = "Rounding")

# Load packages
library(data.table)
library(magrittr)

# Path to each the binary files containing bootstrap results. There is a file
# for each iteration.
unzip("./analysis/bootstrap/output/bootstrap_land_use_models_glopl-5270877.zip",
      exdir = "./analysis/bootstrap/output")
rdas <- list.files(path = "./analysis/bootstrap/output/bootstrap_land_use_models_glopl-5270877/",
                   pattern = ".*\\.rda$",
                   full.names = TRUE)

coef_lst <- vector(mode = "list", length = length(rdas))

for (i in 1:length(coef_lst)){
  load(rdas[i])
  coef_lst[[i]] <- lapply(coef_boot,
                          function(x){
                            tryCatch(as.data.frame(x),
                                     error = function(cond) data.frame(NA))
                          })
  rm(coef_boot)
}

cis <- coef_reformat_lst <- vector(mode = "list", 
                                   length = sapply(coef_lst[[1]], nrow) %>% sum)
j <- 1L

# We purposely used 520 iterations because some can fail. Will select 500 valid
# iterations.
n_boot_round <- 500

# For each kind of set of coefficients, do:
for (i in names(coef_lst[[1]])){
  # Select coefficients, skip NA-s
  coef_dt <- rbindlist(lapply(coef_lst, "[[", i), idcol = "boot")
  n_boot <- length(coef_lst) - sum(is.na(coef_dt$V1)) # number of successful iterations
  coef_dt <- coef_dt[!is.na(V1)]
  coef_names <- rownames(coef_lst[[1]][[i]])
  coef_dt[, coef := rep(coef_names, n_boot)]
  
  # For each coefficient case, compute descriptive stats
  for (cfn in coef_names){
    # Select round values from the bootstrap amount available
    set.seed(321)
    idx <- sample.int(n = n_boot,
                      size = min(n_boot, n_boot_round),
                      replace = FALSE)
    dt <- coef_dt[coef == cfn][idx]
    cf <- dt[["V1"]]
    quant_ci <- quantile(cf, probs = c(0.025, 0.975)) # 95% CI limits
    
    cfn_x <- gsub(pattern = ":", replacement = "_x_", x = cfn)
    model_coef <- paste0(i, "_", cfn_x) 
    
    # Stats
    cis[[j]] <- data.frame(avg = mean(cf),
                           sd = sd(cf),
                           ci_low = quant_ci[1],
                           ci_up = quant_ci[2],
                           model = i,
                           coef_name = cfn_x)
    
    # Save table of coef for later use
    dt[, model := i]
    coef_reformat_lst[[j]] <- copy(dt)
    
    j <- j + 1L
  }
}

all_coef_dt <- rbindlist(cis)

# Use a lookup table to rename the coefficients as in the manuscript.
coef_names_tbl <- fread("./analysis/bootstrap/coef_names.csv")
all_coef_dt <- merge(x = all_coef_dt,
                     y = coef_names_tbl,
                     by = "coef_name")
setorder(all_coef_dt, model, coef_name_manuscript)
setcolorder(all_coef_dt, neworder = c("avg", "sd", "ci_low", "ci_up", 
                                      "model", "coef_name", "coef_name_manuscript"))

write.csv(all_coef_dt,
          file = "./analysis/bootstrap/output/boot_coef_table_ci.csv",
          row.names = FALSE)
