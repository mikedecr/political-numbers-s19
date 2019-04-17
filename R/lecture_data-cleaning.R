# ----------------------------------------------------
#   Data cleaning
# ----------------------------------------------------

# packages
library("tidyverse")
library("here")

# dealing with model output!
library("broom")




# ---- data shaping -----------------------

# an example of what "wide data" looks like
AirPassengers


# This object has weird properties, 
#   so I need to fix it to make it a better example.
# You should run this chunk but can ignore what it does
wide_air <- AirPassengers %>%
  as_tibble() %>%
  rename(passengers = x) %>%
  mutate(
    year = time(AirPassengers) %>%
           as.integer(), 
    month = cycle(AirPassengers) %>% 
            month.abb[.]
  ) %>%
  spread(key = month, value = passengers) %>%
  select(year, one_of(month.abb))


# OK now `wide_air` is a typical wide dataset
wide_air


# we want it to be "long" using gather()

# how to use gather()
# It basically "stacks" variables on top of one another,
#   so multiple variables become one,
#   thus "elongating" the whole table.
# It works like this.
# When you "stack" variables, you want to keep the original names and the data.
#   key = what do you want to call the new variable of labels?
#   value = what do you want to call the data?
#   Then list the variables you want to "stack" (comma sep'd)
#   You can grab a range of variables using : colon.

long_air <- wide_air %>%
  gather(key = month, value = passengers, 
         Jan, Feb, Mar, Apr:Dec) %>%
  print()


# now we can do fun things like ggplot
ggplot(long_air, aes(x = year, y = passengers)) +
  geom_line(aes(color = month)) +
  theme_minimal()


# this graph would be nicer if we could order the months...
# this puts month categories in order according to the `month.abb` object
long_air %>%
  mutate(month = fct_relevel(month, month.abb)) %>%
  ggplot(aes(x = year, y = passengers)) +
  geom_line(aes(color = month)) +
  theme_minimal()




# ---- Merging/joining data -----------------------

# we have two data sets, and we want to put them together


# Dataset 1: murder arrests rate (per 100,000 ppl)
arrests <- USArrests %>% 
  as_tibble(rownames = "state_name") %>% 
  select(state_name, Murder) %>%
  print()


# Dataset 2: poverty data only for midwest states
midwest_poverty <- tibble(state_name = state.name, 
       state = state.abb) %>%
  inner_join(midwest) %>%
  select(state_name, state, poverty = percbelowpoverty, pop = poptotal) %>%
  group_by(state, state_name) %>%
  summarize(mean_poverty = sum((pop / sum(pop)) * poverty)) %>%
  ungroup() %>%
  print()


# inner join: result contains only matching cases in BOTH data
#   (only the midwest states are in both datasets)
inner_matches <- 
  inner_join(arrests, midwest_poverty, by = "state_name") %>%
  print()


# left join: keep all rows from the "left" data, merge what you can
# Here we are merging midwest_poverty (right) into the murder data (left).
# Also, we are arranging to show the effect 
#   (non-matched cases have NA in new variables)

left_matches <- left_join(arrests, midwest_poverty, by = "state_name") %>%
  arrange(mean_poverty) %>%
  print()




# ---- Recoding variables -----------------------


# An example with case_when().
# Usage: case_when(logical_test ~ result)
# Works like: if [logical_test] then [result]

# Unmatched cases default to NA
midwest_poverty %>%
  mutate(is_great = case_when(state == "WI" ~ "Pretty great", 
                              state == "IL" ~ "Medium"))

# Translated:
#   Create a new variable, is_great.
#   if (state is WI), is_great will be equal to 'Pretty great'
#   if (state is IL), is_great will be equal to 'Medium'


# You can do a "catch all" with `TRUE ~ result`
midwest_poverty %>%
  mutate(is_great = case_when(state == "WI" ~ "Pretty great", 
                              state == "IL" ~ "Medium",
                              TRUE ~ "Crappy"))

# Translation:
# for everything else, is_great will be labeled "Crappy"




# Here is an example where I create a "dummy" (aka binary) variable
# Binary variables are either 0 (false) or 1 (true)

# I make a variable that is 1 if I've lived in that state, 
#   and 0 if I haven't

arrests %>%
  mutate(
    placed_ive_lived = case_when(state_name == "Missouri" ~ 1, 
                                 state_name == "California" ~ 1, 
                                 state_name == "Wisconsin" ~ 1, 
                                 TRUE ~ 0)
  ) %>%
  print()




# ---- String manipulation -----------------------

# There are lots of tidyverse functions for working with text data.
# They come from the {stringr} package (in case you want to google more)


# let's make a string (aka 'character') variable
my_string <- c("a", "b", "cdef")
my_string


# does a string contain a particular pattern?
# returns a logical result, TRUE or FALSE for each element in my_string
str_detect(my_string, pattern = "b")


# replace a character pattern.
# if the element contains 'b', replace it with 'bee'
str_replace(my_string, pattern = "b", replace = "bee")


# trim a string to a substring
# This example: grab the first two characters from each element
str_sub(my_string, start = 1, end = 2) 



