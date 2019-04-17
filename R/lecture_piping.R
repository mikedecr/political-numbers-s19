# ----------------------------------------------------
#   THE PIPE OPERATOR
#   Code from lecture (Feb 25)
# ----------------------------------------------------

# ---- data -----------------------

library("tidyverse")

# COUNTY-level data from Midwest states
midwest





# ----------------------------------------------------
#   Doing a chain of things. How?
#   This section contains ways NOT to do it
# ----------------------------------------------------


# ---- Overwrite the original object? ----------------

# all tidyverse functions: first argument is the DATASET
# MUTATE
# first, find the number of children (total minus adults)
# then, find the proportion (children / total)
midwest <- mutate(midwest, 
                  popchildren = poptotal - popadults, 
                  pr_children = popchildren / poptotal)

# group by state
midwest <- group_by(midwest, state)

# mean pr_children by state
summarize(midwest, mean_pr_children = mean(pr_children))



# ---- create intermediate objects? -----------------------

# create a new object, 
#   which gets results from mutate()
midwest_mut <- mutate(midwest, 
                      popchildren = poptotal - popadults, 
                      pr_children = popchildren / poptotal)

# group the NEW OBJECT by state
midwest_grp <- group_by(midwest_mut, state)

# Summarize the GROUPED OBJECT
summarize(midwest_grp, mean_pr_children = mean(pr_children))


# ---- order of operations?? -----------------------

# PSA: never do this

# we know that every f() creates a new data frame
# so we can pass results to next function: f(g(h(x)))

# FROM THE INSIDE OUT: mutate() the midwest data
# Then, mutate() result is the data for group_by()
# Then, group_by() result is the data for summarize()

# reminder: never do this
summarize(
  group_by(
    mutate(midwest, 
           popchildren = poptotal - popadults, 
           pr_children = popchildren / poptotal), 
    state), 
  mean_pr_children = mean(pr_children)
)

# have I mentioned that you should never do this?







# ----------------------------------------------------
#   THE PIPE OPERATOR
# ----------------------------------------------------


# enter... the pipe operator %>%
# read it as "and then..."
midwest %>%
  mutate(popchildren = poptotal - popadults,
         pr_children = popchildren / poptotal) %>%
  group_by(state) %>%
  summarize(mean_pr_children = mean(pr_children))




# ---- code w/ and w/out the pipe -----------------------

# Typical R code: f(data)
dim(midwest)


# With the pipe: data %>% f()
# Data serves as first arg in f() (implicitly)
midwest %>% dim()



# ---- another example, multiple functions -----------------------

# Typical R code: f(g(x))
# g() is first, then f()
length(names(midwest))


# with the pipe: data %>% g() %>% f()
# just as it should be
midwest %>% names() %>% length()

# or, break across lines for readability
midwest %>% 
  names() %>% 
  length()



# ----------------------------------------------------
#   Make our own chains!!!!
# ----------------------------------------------------

# ---- Example 1 -----------------------

# 1. Start with `midwest`
# 2. For each state, count metro/non-metro area counties (`inmetro`)

midwest %>% 
  group_by(state) %>% 
  count(inmetro)




# ---- Example 2 -----------------------
# 1. Start with `gapminder` (need to load it)
# 2. For each year, keep the country with the highest GDP per capita
# 3. sort by year

library("gapminder")

gapminder %>% 
 group_by(year) %>% 
 filter(gdpPercap == max(gdpPercap)) %>% 
 arrange(year)





# ----------------------------------------------------
#   Pipe tips!
# ----------------------------------------------------

# ---- printing the results of a chain -----------------------

# results don't print when you make new object
just_WI <- midwest %>%
  filter(state == "WI")

# But they do with print()
just_WI <- midwest %>%
  filter(state == "WI") %>%
  print()



# ---- What if the first arg isn't data = ? -----------------------

# linear relationship between poverty (y) and education (x)
# notice location of data = 
lm(percelderlypoverty ~ percollege, data = midwest)


# use a period to stand in for the piped data
midwest %>%
  lm(percelderlypoverty ~ percollege, data = .)



