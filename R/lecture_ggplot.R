# ----------------------------------------------------
#   Code from lecture on ggplot
#   - Follow along with existing code, or
#   - Re-type the code yourself to get the feel for it
# ----------------------------------------------------



# ---- Getting oriented -----------------------

# we need to load packages to help us run the following code

# {tidyverse} contains ggplot tools, should already be installed
library("tidyverse")

# install these two packages if you haven't already
install.packages("gapminder") # contains dataset
install.packages("here")      # easier to save things

# load the installed packages
library("gapminder")
library("here")




# ---- Meet the data -----------------------

# print the data
gapminder

# variable names
names(gapminder)






# ---- Modified data objects -----------------------

# create a new object: 'gapminder' for most recent year
gap07 <- filter(gapminder, year == 2007)

# this means: 
# - filter rows out of the gapminder data. 
# - We want to keep rows where `year` is equal to (==) 2007


# create a new object: the subset of 'gapminder' where continent is "Oceania"
gapOC <- filter(gapminder, continent == "Oceania")

# - keep rows where `continent` is equal to (==) "Oceania")

# What's left?
gap07
gapOC





# ---- Start our first plot -----------------------

ggplot(data = gap07, mapping = aes(x = gdpPercap, y = lifeExp))

# data = 
# - tell ggplot() which data we're using

# mapping =
# - plot-level aesthetic mappings, usually for x and y axes





# ---- Geoms: Add points -----------------------

ggplot(data = gap07, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point() 

# notice the `+` on the first line.
# This prevents R from ending the command on the first line,
#   so it looks to the next line to finish the statement.






# ---- Aesthetics: point color -----------------------

ggplot(data = gap07, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(color = continent)) 

# means "use different point colors for different continents"


ggplot(data = gap07, mapping = aes(x = gdpPercap, y = lifeExp)) +
 geom_point(color = "blue") 



# ---- Axis and Legend Labels -----------------------

ggplot(data = gap07, mapping = aes(x = gdpPercap, y = lifeExp)) +
  geom_point(aes(color = continent)) +
  labs(x = "GDP per Capita ($US, Inflation Adjusted)",
       y = "Life Expectancy (Years)",
       color = NULL,
       title = "National Economy and Life Expectancy",
       subtitle = "Data from 2007")

# You can label any aesthetic that you have mapped from data!





# ---- save an existing plot -----------------------

ggsave(here("figures", "my-plot.pdf"), height = 3, width = 5)

# tell ggsave() where to save the plot
# - inside the 'figures' folder, as a file called 'my-plot.pdf'
# - you can use whatever file name you want but be smart

# also set the height and width of the saved image
# (default unit is inches but that can be customized)





# ---- Second graphic: line plot of Oceania data -----------------------

ggplot(gapOC, aes(x = year, y = lifeExp))

# using the Oceania data
# We don't need to type 'data =' or `mapping =` 
#   as long as you write it in this order





# ---- Geoms and Aesthetics: Add lines w/ different color and style -------

ggplot(gapOC, aes(x = year, y = lifeExp)) + 
  geom_line(aes(linetype = country, 
                color = country)) 

# if we didn't map aesthetics for the line, 
#   ggplot would try to connect all data with a single line
#   and we wouldn't want that



# ---- Tabulating a variable with count() -----------------------

# Because remember, there are two countries in this OC data
count(gapOC, country)


# count() tabulates a variable within a data frame
# - tell it which dataset to use
# - which variable do you want to tabulate?
# - Result is a new data frame telling you how many obs per category





# ---- Scales: override the default color mapping -----------------------

ggplot(gapOC, aes(x = year, y = lifeExp)) + 
  geom_line(aes(linetype = country, color = country)) +
  scale_color_brewer(palette = "Dark2")

# this function lets you specify which color palette you want to use




# ---- Scales: manually specify colors -----------------------

ggplot(gapOC, aes(x = year, y = lifeExp)) + 
  geom_line(aes(linetype = country, color = country)) +
  scale_color_manual(values = c("Australia" = "dodgerblue", 
                                "New Zealand" = "orangered")) 





# ---- Coordinate settings -----------------------

ggplot(gapOC, aes(x = year, y = lifeExp)) + 
  geom_line(aes(linetype = country, color = country)) +
  coord_cartesian(xlim = c(1950, 2010))

# xlim and ylim arguments want vectors of information
# - a minimum value and a maximum value
# - this says "x axis goes between 1950 and 2010"





# ---- Scales: axes are aesthetics too -----------------------

ggplot(gapOC, aes(x = year, y = lifeExp)) + 
  geom_line(aes(linetype = country, color = country)) +
  coord_cartesian(xlim = c(1950, 2010)) +
  scale_x_continuous(breaks = seq(1950, 2010, 20)) + 
  labs(x = NULL, y = "Life Expectancy (Years)", 
       color = NULL, linetype = NULL) 

# `x` is an aesthetic that you mapped *from the data
# - so that means you can modify it with a scale_* function
# - "breaks" means "where do axis ticks go"
# - seq() creates a sequence of values between 1950 and 2010, in 20-year increments





# ---- Last plot: histogram with facets -----------------------

# using the full gapminder data now: all countries and all years
ggplot(gapminder, aes(x = lifeExp))

# if we want to make a histogram, we don't specify y aesthetic
# - this is because the histogram will calculate y itself






# ---- Facets (wrapping) -----------------------

ggplot(gapminder, aes(x = lifeExp)) +
  facet_wrap(~ year) 

# the tilde is necessary 
# facet_wrap creates panels that can "wrap" across multiple lines






# ---- Geom: histogram -----------------------

ggplot(gapminder, aes(x = lifeExp)) +
  facet_wrap(~ year) +
  geom_histogram()

# Section lesson contains code to modify the histogram's bin size and stuff






# ---- Facets: grid -----------------------

ggplot(gapminder, aes(x = lifeExp)) +
  facet_grid(continent ~ year) +
  geom_histogram(fill = "white", color = "black")

# facet_grid(row_variable ~ column_variable)
# - this example: different continents in different rows
# - different years in different columns

