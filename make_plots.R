library(ggplot2)
library(dplyr)
library(stringr)
library(latex2exp)
library(scales)

datadir <- "C:\\Users\\oconn\\Dropbox\\Research\\OTC_Experiments\\Data"
file <- "runtime_exp_2021_08_31_02_26_08_results.csv"
options(stringsAsFactors=FALSE)

## Read Data.
all_data <- read.csv(file.path(datadir, file), header=TRUE, stringsAsFactors=FALSE)
head(all_data)

## Wrangle data
runs_per_iter <- length(unique(all_data$Xi))
n_dims <- length(unique(all_data$d))
total_runs <- nrow(all_data)
n_iters <- total_runs / (n_dims*runs_per_iter)
iters <- rep(rep(1:n_iters, each=runs_per_iter), n_dims)
all_data$Iter <- iters

# Error data
error_data <- all_data %>%
  group_by(d, Iter) %>% 
  mutate(Error=Cost-Cost[Algorithm=="ExactOTC"])
error_data <- error_data %>%
  group_by(d, Xi) %>%
  summarise(
    "Mean_Error"=mean(Error),
    "Max_Error"=max(Error),
    "Min_Error"=min(Error)
  ) %>%
  filter(Xi != "Inf")

# Runtime data
runtime_data <- all_data %>% 
  group_by(d, Xi) %>% 
  summarise("Mean_Runtime"=mean(Runtime),
            "Max_Runtime"=max(Runtime),
            "Min_Runtime"=min(Runtime))

## Make plots
plot_id <- format(Sys.time(), "%m-%d-%y_%H-%M-%S")

# Plot runtimes
alg <- ifelse(runtime_data$Xi=="Inf", "Exact", "Entropic")
alg_factor <- interaction(factor(runtime_data$Xi), factor(alg, levels=c("Exact", "Entropic")))
ggplot(runtime_data, 
       aes(x=d, y=Mean_Runtime/1e3, color=alg_factor)) + 
  #geom_line(aes(linetype=factor(alg, levels=c("Exact", "Entropic"))), size=2) + 
  geom_line(size=2) + 
  geom_point(size=2) + 
  geom_errorbar(aes(ymin=Min_Runtime/1e3, 
                    ymax=Max_Runtime/1e3),
                width=1,
                size=1) +
  theme_minimal() +
  theme(legend.position = c(0.25,0.65),
        legend.title = element_text(size=20), 
        legend.text = element_text(size=18),
        legend.title.align=0.5,
        legend.text.align = 0,
        legend.box.background = element_rect(colour="black"),
        plot.title = element_text(size=20, face="bold"),
        axis.text = element_text(size=18),
        axis.title = element_text(size=18, face="bold"))+
  scale_color_manual(
    values=c("Inf.Exact"="black", "75.Entropic"=hue_pal()(3)[1], "100.Entropic"=hue_pal()(3)[2], "200.Entropic"=hue_pal()(3)[3]),
    labels=unname(TeX(c("ExactOTC", "EntropicOTC, $\\xi$=75", "EntropicOTC, $\\xi$=100", "EntropicOTC, $\\xi$=200")))) + 
  ggtitle("Runtime") + 
  labs(
    color = "Algorithm",
    y = expression(Runtime~("10"^"3"~s))) + 
  guides(linetype=FALSE)
ggsave(file.path(datadir, paste0("runtime_plot_", plot_id, ".png")), width=8, height=5)

# Plot errors
ggplot(error_data, 
       aes(x=d, y=Mean_Error*1e3, group=factor(Xi), color=factor(Xi))) + 
  geom_line(size=2) + 
  geom_point(size=2) + 
  geom_errorbar(aes(ymin=Min_Error*1e3, 
                    ymax=Max_Error*1e3),
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
  ggtitle("Error of EntropicOTC") + 
  labs(group = "xi",
       color = TeX('$\\xi$'),
       y = expression(Error~("10"^"-3")))
ggsave(file.path(datadir, paste0("error_plot_", plot_id, ".png")))

