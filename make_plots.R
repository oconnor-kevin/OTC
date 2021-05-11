library(ggplot2)
library(dplyr)
library(stringr)
library(latex2exp)

homedir <- "/Users/kevinoconnor/Documents/Research/OptimalJoinings/OT_via_PIA"
datadir <- file.path(homedir, "Data")
options(stringsAsFactors=FALSE)

## Read Data.
xi_to_keep <- c(75, 100, 200)
files_vec <- list.files(datadir)
# Subset to csv files.
is_csv <- sapply(files_vec, function(x){grepl(".csv", x)})
files_vec <- files_vec[is_csv]
# Aggregate data.
all_data <- data.frame("measure"=character(),
                       "algorithm"=character(),
                       "d"=integer(),
                       "xi"=integer(),
                       "sinkiter"=integer(),
                       "value"=double())
for (file in files_vec){
  # Get parameters
  xi <- as.numeric(str_match(file, "xi(.*?)_")[2])
  if (xi %in% xi_to_keep){
    is_approx <- grepl("approx", file)
    is_cost <- grepl("costs", file)
    algorithm <- ifelse(is_approx, "FastEntropicOTC", "ExactOTC")
    measure <- ifelse(is_cost, "Costs", "Runtimes")
    sinkiter <- as.numeric(str_match(file, "sinkiter(.*?)_")[2])
    # Get file data
    file_data <- read.csv(file.path(datadir, file), header=FALSE, stringsAsFactors=FALSE)
    # Append to dataframe
    for (r in 1:nrow(file_data)){
      for (c in 1:ncol(file_data)){
        d <- r*10
        all_data <- rbind(all_data, list("measure"=measure, 
                                         "algorithm"=algorithm, 
                                         "d"=d, 
                                         "xi"=xi, 
                                         "sinkiter"=sinkiter, 
                                         "value"=file_data[r, c]))
      }
    }
  }
}

## Wrangle data
# Cost data
cost_data <- all_data %>% filter(measure=="Costs")
error_vec <- filter(cost_data, algorithm=="FastEntropicOTC")$"value" - 
  filter(cost_data, algorithm=="ExactOTC")$"value"
error_data <- cost_data %>% 
  filter(algorithm=="FastEntropicOTC") %>%
  select("d", "xi", "sinkiter")
error_data$"error" <- error_vec
error_data <- error_data %>%
  group_by(d, xi) %>%
  summarise("mean_error"=mean(error),
            "max_error"=max(error),
            "min_error"=min(error))
# Runtime data
time_data <- all_data %>% filter(measure=="Runtimes")
runtime_diff_vec <- filter(time_data, algorithm=="ExactOTC")$"value" - 
  filter(time_data, algorithm=="FastEntropicOTC")$"value"
runtime_diff_data <- time_data %>%
  filter(algorithm=="FastEntropicOTC") %>%
  select("d", "xi", "sinkiter")
runtime_diff_data$"time_diff" <- runtime_diff_vec
runtime_diff_data <- runtime_diff_data %>% 
  group_by(d, xi) %>% 
  summarise("mean_time_diff"=mean(time_diff),
            "max_time_diff"=max(time_diff),
            "min_time_diff"=min(time_diff))

## Make plots
plot_id <- format(Sys.time(), "%m-%d-%y_%H-%M-%S")
# Times
ggplot(runtime_diff_data, 
       aes(x=d, y=mean_time_diff/1e3, group=factor(xi), color=factor(xi))) + 
  geom_line(size=2) + 
  geom_point(size=2) + 
  geom_errorbar(aes(ymin=min_time_diff/1e3, 
                    ymax=max_time_diff/1e3),
                width=1,
                size=1) +
  theme_minimal() +
  theme(legend.position = c(0.1,0.75),
        legend.title = element_text(size=20), 
        legend.text = element_text(size=18),
        legend.title.align=0.5,
        legend.box.background = element_rect(colour="black"),
        plot.title = element_text(size=20, face="bold"),
        axis.text = element_text(size=18),
        axis.title = element_text(size=18, face="bold"))+
  ggtitle("Difference in Runtime") + 
  labs(group = "xi",
       color = TeX('$\\xi$'),
       y = expression(Difference~"in"~Runtime~("10"^"3"~s)))
ggsave(file.path(homedir, paste0("runtime_diff_plot_", plot_id, ".png")))

# Errors
ggplot(error_data, 
       aes(x=d, y=mean_error*1e3, group=factor(xi), color=factor(xi))) + 
  geom_line(size=2) + 
  geom_point(size=2) + 
  geom_errorbar(aes(ymin=min_error*1e3, 
                    ymax=max_error*1e3),
                width=1,
                size=1) +
  theme_minimal() +
  theme(legend.position = c(0.1,0.75),
        legend.title = element_text(size=20), 
        legend.text = element_text(size=18),
        legend.title.align = 0.5,
        legend.box.background = element_rect(colour="black"),
        plot.title = element_text(size=20, face="bold"),
        axis.text = element_text(size=18),
        axis.title = element_text(size=18, face="bold"))+
  ggtitle("Error of FastEntropicOTC") + 
  labs(group = "xi",
       color = TeX('$\\xi$'),
       y = expression(Error~("10"^"-3")))
ggsave(file.path(homedir, paste0("error_plot_", plot_id, ".png")))

