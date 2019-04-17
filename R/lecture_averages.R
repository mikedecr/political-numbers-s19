# ----------------------------------------------------
#   Tidyverse examples from Lecture 08 (Averages)
# ----------------------------------------------------

# load tidyverse and gapminder data
library("tidyverse")
library("gapminder")


# ---- arrange (sort data) -----------------------

# With tidyverse verbs, the first argument is the data frame
# Sort by year and then by continent.

arrange(gapminder, year, continent)



# ---- select: keep columns/variables -----------------------

# Which variables do I want to keep?
# Again, first arg is the data frame name
# (notice lack of $)

select(gapminder, country, year, gdpPercap)



## ----filter: keep observations/rows -----------------------------------

# Which cases (rows) do I want to keep?
# filter(dataset, logical test)
# keep rows where test result is TRUE

filter(gapminder, country == "United States")

# here is the logical test by itself:
# Which observations of `country` are "United States"
gapminder$country == "United States"




# ---- mutate: add/modify variables -----------------------

# mutate(dataframe, new_variable = (whatever you want))

mutate(gapminder, 
       gdp = gdpPercap * pop)


# ---- count: tabulate variable(s) -----------------------

# tabulate variable(s) with count().
# Again... result is a DATA FRAME

count(gapminder, continent, year)



# ---- summarize: calculate summary stats -----------------------

# New data frame of summary calculations
# Use na.rm = TRUE to skip missing values when calculating summary stats

summarize(gapminder, 
          mean_lifeexp = mean(lifeExp),
          min_lifeexp = min(lifeExp),
          max_lifeexp = max(lifeExp, na.rm = TRUE))



# ---- group_by: partition the data into groups -----------------------

group_by(gapminder, continent) 



# ---- group_by & summarize: summarize within groups -----------------------

gap_by_continent <- group_by(gapminder, continent)

summarize(gap_by_continent, mean_life = mean(lifeExp))


# Because result of group_by() is a data frame,
#  you could pass result directly to summarize

summarize(group_by(gapminder, continent),
          mean_life = mean(lifeExp))






# ---- CODE FOR AVERAGING EXAMPLES -----------------------


# quantitative variables
summarize(gapminder, 
          avg_lifeexp = mean(lifeExp), 
          avg_gdpPercap = mean(gdpPercap))


# categorical variables
# example: proportion of data in select continents
summarize(gapminder,
          pr_afr = mean(continent == "Africa"),
          pr_euro = mean(continent == "Europe"))


