library(pheatmap)
library(dplyr)

## Experiment parameters
homedir <- getwd() # Set home directory
savedir <- getwd()  # Directory to save plots in. Defaults to home directory.
datadir <- file.path(homedir, "Data") 
exp_id <- "2021_09_16_12_32_17" # Set experiment ID to select results from the correct run.

## Read data
exp_costs <- read.csv(file.path(datadir, paste0("music_exp_", exp_id, "_expcosts.csv")))
song_vec <- read.csv(file.path(datadir, paste0("music_exp_", exp_id, "_song_list.csv")), header=FALSE)[,1]
key_vec <- read.csv(file.path(datadir,  paste0("music_exp_", exp_id, "_key_list.csv")), header=FALSE)[,1]
composer_vec <- read.csv(file.path(datadir,  paste0("music_exp_", exp_id, "_composer_list.csv")), header=FALSE)[,1]

## ExactOTC
dist_mat <- as.matrix(read.csv(file.path(datadir, paste0("music_exp_", exp_id, "_exactotc_distmat.csv")), header=FALSE))

# Filter data
to_keep <- which(composer_vec != "sor" & composer_vec != "chopin")
dist_mat <- dist_mat[to_keep, to_keep]
song_vec <- song_vec[to_keep]
key_vec <- key_vec[to_keep]
composer_vec <- composer_vec[to_keep]

# Heatmap
rownames(dist_mat) <- 1:ncol(dist_mat)
colnames(dist_mat) <- 1:ncol(dist_mat)
jpeg(file=file.path(savedir, paste0("music_exp_", exp_id, "_exactotc_heatmap.jpg")))
pheatmap(as.matrix(dist_mat), treeheight_row = 0, treeheight_col = 0)
dev.off()

# Get best pairs
best_idxs <- order(exp_costs$exactotc_cost)[1:5]
exp_costs[best_idxs,1:2]


## EntropicOTC
dist_mat <- as.matrix(read.csv(file.path(datadir,  paste0("music_exp_", exp_id, "_entropicotc_distmat.csv")), header=FALSE))

# Filter data
to_keep <- which(composer_vec != "sor" & composer_vec != "chopin")
dist_mat <- dist_mat[to_keep, to_keep]
song_vec <- song_vec[to_keep]
key_vec <- key_vec[to_keep]
composer_vec <- composer_vec[to_keep]

# Heatmap
rownames(dist_mat) <- 1:ncol(dist_mat)
colnames(dist_mat) <- 1:ncol(dist_mat)
jpeg(file=file.path(savedir, paste0("music_exp_", exp_id, "_entropicotc_heatmap.jpg")))
pheatmap(as.matrix(dist_mat), treeheight_row = 0, treeheight_col = 0)
dev.off()

# Best pairs
best_idxs <- order(exp_costs$entropicotc_cost)[1:5]
exp_costs[best_idxs,1:2]
