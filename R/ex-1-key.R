# ----------------------------------------------------
#   Exercise 1: solutions
# ----------------------------------------------------


# ---- 0. prep ---------

getwd()

list.files()

list.files("data")


# ---- 1. Load {tidyverse} and {here} packages ---------

library("tidyverse")
library("here")


# ---- 2. Read data into R using read_csv() -----------------

# must change file name to match downloaded data!
polls <- read_csv(here("data", "ex-1_polls_fl-oh-va.csv"))


# ---- 3. Print data, inspect names --------------

polls

names(polls)


# ---- 4. Polls per state -----------------------

# all tidyverse functions start with dataframe
count(polls, state_abb)

# with piping: 
# - start with data
# - then send to count()

polls %>%
  count(state_abb)


# ---- 5. Histogram -----------------------

# sufficient
ggplot(polls, aes(x = obama_margin)) +
  geom_histogram() +
  facet_wrap(~ state_abb) +
  labs(x = "Obama Margin", y = "Number of Polls") 


# PIZAZZ VERSION

# Histogram tips:
# - bindwidth: set width of each bar
# - boundary: should bars be centered or offset on axis labels?

# other tips: 
# - vertical line at x = 0
# - vertical alignment of states to compare margins easily
# - modify labeling of the x axis scale

ggplot(polls, aes(x = obama_margin)) +
  geom_histogram(binwidth = .01, boundary = TRUE,
                 color = "black", fill = "gray80") +
  geom_vline(xintercept = 0, color = "maroon") +
  facet_grid(state_abb ~ .) +
  labs(x = "Obama Margin", y = "Number of Polls") +
  scale_x_continuous(breaks = seq(-0.1, 0.1, 0.05),
                     labels = scales::percent) +
  theme_minimal()

ggsave(here("figures", "ex-1_histogram.pdf"), height = 6, width = 5)



# ---- 6. Dem two party vote -----------------------

# non-pipe version
polls <- mutate(polls, dem_2party = obama / (obama + romney))

# piping style
polls <- polls %>%
  mutate(dem_2party = obama / (obama + romney)) %>%
  print()


# investigate what you've done
polls %>% 
  select(obama, romney, dem_2party)


# ---- 7. Mean two-party vote in each state ----------------

# -- filtering method -- 
FL <- filter(polls, state_abb == "FL")
OH <- filter(polls, state_abb == "OH")
VA <- filter(polls, state_abb == "VA")

# piping would work too. 
# polls %>% filter(...)

summarize(FL, mean_2p = mean(dem_2party))
summarize(OH, mean_2p = mean(dem_2party))
summarize(VA, mean_2p = mean(dem_2party))


# pipe group-and-summarize (THE BEST WAY)
polls %>%
  group_by(state_abb) %>%
  summarize(mean_2p = mean(dem_2party)) 


# group-and-summarize without the pipe is cumbersome but works
summarize(group_by(polls, state_abb),
          mean_2p = mean(dem_2party)) 




