library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)

## Experiment parameters
homedir <- getwd() # Set home directory
savedir <- getwd()  # Directory to save plots in. Defaults to home directory.
datadir <- file.path(homedir, "GeneratedPieces") 
expid <- "2021_09_16_12_32_17" # Set experiment ID to select results from the correct run.
piece_str <- "bach-book1-fugue02-cminorbeethoven-piano-sonata-pathetique-2-cminor"
piece1_name <- "Bach - Book 1, Fugue 2"
piece2_name <- "Beethoven - Piano Sonata Pathetique, 2nd Movement"
start <- 21  # What idx in sequence to start with
stop <- 44   # What idx in sequence to end with

## ExactOTC
notes <- read.csv(file.path(datadir, paste0(piece_str, expid, "_exact_otc.csv")), header=FALSE)[-c(1:6),]

# Separate tracks
track1_inds <- which(notes[,1] == 2 & !is.na(notes[,4]))
track2_inds <- which(notes[,1] == 3 & !is.na(notes[,4]))
notes1 <- notes[track1_inds[seq(1, length(track1_inds), 2)],5]
notes2 <- notes[track2_inds[seq(1, length(track2_inds), 2)],5]
notes1_df <- data.frame(time=1:length(notes1), key=notes1)
notes2_df <- data.frame(time=1:length(notes2), key=notes2)

# Add note names
notes <- c("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")
notes1_df <- notes1_df %>%
  mutate(octave=(key-11) %/% 12, 
         note=paste0(notes[ifelse((key-11) %% 12 == 0, 12, (key-11) %% 12)], ifelse((key-11) %% 12 == 0, octave-1, octave)))
notes2_df <- notes2_df %>%
  mutate(octave=(key-11) %/% 12, 
         note=paste0(notes[ifelse((key-11) %% 12 == 0, 12, (key-11) %% 12)], ifelse((key-11) %% 12 == 0, octave-1, octave)))

# Add indicator for octave / perfect / imperfect unison
notes1_df$consonance <- rep("dissonant", nrow(notes1_df))
notes2_df$consonance <- rep("dissonant", nrow(notes2_df))
notes1_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) == 0)] <- "unison"
notes2_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) == 0)] <- "unison"
notes1_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) %in% c(5, 7))] <- "perfect"
notes2_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) %in% c(5, 7))] <- "perfect"
notes1_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) %in% c(4, 9))] <- "imperfect"
notes2_df$consonance[which((abs(notes1_df$key - notes2_df$key) %% 12) %in% c(4, 9))] <- "imperfect"

# Subset to section of interest
notes1_df_full <- notes1_df;
notes2_df_full <- notes2_df
notes1_df <- notes1_df[start:stop,]
notes2_df <- notes2_df[start:stop,]

# Add time
notes1_df["time"] <- 1:nrow(notes1_df)
notes2_df["time"] <- 1:nrow(notes2_df)

# Make plot
notes_df <- rbind(notes1_df, notes2_df)
notes_df$piece <- c(rep(piece1_name, nrow(notes1_df)), rep(piece2_name, nrow(notes2_df)))

ggplot(notes_df) + 
  scale_x_continuous(name="Time", expand=c(0, 0), breaks=seq(1, nrow(notes1_df), 4)) + 
  scale_y_continuous(name="Note", expand=c(0, 0), breaks=seq(9,100,12)) +
  geom_rect(mapping=aes(xmin=time, xmax=time+1, ymin=key-0.5, ymax=key+0.5, fill=consonance), color="black", alpha=0.5, show.legend=TRUE) +
  geom_text(aes(x=time+0.3, y=key, label=note), size=1.75, show.legend=FALSE) + 
  theme(axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.x=element_blank(),
        panel.grid.minor = element_blank(),
        strip.background = element_blank(),
        strip.text.x = element_text(face = "bold", hjust=0)) + 
  guides(fill = guide_legend(reverse = TRUE)) +
  scale_fill_brewer(palette="PuBu", name="Consonance") + 
  facet_wrap(~ piece, nrow=2) + 
  ggsave(file.path(savedir, paste0("music_exp_", exp_id, piece_str, "_exactotc_samples.png")), height=6, width=6.49)
