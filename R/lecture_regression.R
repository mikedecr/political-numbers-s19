# ----------------------------------------------------
#   Regression code
#   with tips for ggplot and exercise 2
# ----------------------------------------------------

library("tidyverse")




# ----------------------------------------------------
#   ggplot tips (Ex 2)
# ----------------------------------------------------


# ---- Specifying data for geoms -----------------------

# geoms inherit data from ggplot(),
#   but you can re-declare different data
ggplot(data = midwest, aes(x = percollege, y = percprof)) +
  geom_point(color = "gray") +
  geom_point(data = filter(midwest, state == "IN"), # a subset of data
             color = "black", 
             size = 2)




# ---- Annotating a graphic -----------------------

# You can annotate with any geom, but here we want text.
# We specify the x, y values; and the label that gets printed
ggplot(data = midwest, aes(x = percollege, y = percprof)) +
  geom_point(color = "gray") +
  geom_point(data = filter(midwest, state == "IN"), 
             color = "black", 
             size = 2)  +
  annotate(geom = "text", x = 15, y = 7, label = "Indiana")




# ---- Using a logical for aes() mapping -----------------------

# demonstrating a logical:
# Is state equal to IN?
midwest$state == "IN"


# create a new variable contianing this logical 
midwest2 <- midwest %>%
  mutate(is_indiana = (state == "IN")) %>%
  print()

# looking at what we've done
select(midwest2, state, is_indiana)

# tabulating to see if it worked correctly
midwest2 %>% 
  count(state, is_indiana)


# map color to is_indiana
ggplot(data = midwest2, aes(x = percollege, y = percprof)) +
  geom_point(aes(color = is_indiana)) #<<

# ---- suppressing a legend -----------------------

# also we create the logical within aes()
# and customizing colors
ggplot(data = midwest, aes(x = percollege, y = percprof)) +
  geom_point(
    aes(color = (state == "IN")), #<< 
    show.legend = FALSE, #<<
  ) + 
  annotate(geom = "text", x = 15, y = 7, label = "Indiana") +
  # customize colors, scale_aes_*()
  scale_color_manual( #<<
    values = c("TRUE" = "maroon", #<<
               "FALSE" = "gray") #<<
  ) #<<

# TRUE and FALSE are labels of the logical
# we're saying TRUE units (IN) get maroon, FALSE units (not IN) get gray



# ---- abline -----------------------

# default behavior: vertical line at y = x
# (intercept = 0, slope = 1)
# but you can also specify slope and intercept

# this is random data getting piped into ggplot
tibble(
  x = rnorm(100), 
  y = 0.5*x + rnorm(100)
) %>%
  ggplot(aes(x, y)) +
    geom_point() +
    geom_abline() +
    geom_smooth(method = "lm") +
    annotate("text", x = 2.5, y = 4.5, label = "geom_abline()") +
    annotate("text", x = 4, y = 1, label = 'geom_smooth()') +
    coord_cartesian(xlim = c(-5, 5), ylim = c(-5, 5))




# ----------------------------------------------------
#   Regression
# ----------------------------------------------------

# here is the example we keep seeing

ggplot(midwest, aes(percollege, percprof)) +
  geom_point(color = "gray") +
  geom_smooth(color = "black", method = "lm", se = FALSE) +
  labs(x = "Percent w/ College Degree",
       y = "Percent w/ Prof. Degree",
       title = "College and Professional Education",
       subtitle = "Data from Midwestern Counties")



# ---- plotting the WI graphic w/ residuals -----------------------

# install.packages("broom")

# keep only WI
# estimate the model using lm()
# augment() makes new data frame with...
# - x data and y data
# - predictions, residuals, other stuff
regdata <- midwest %>%
  filter(state == "WI") %>%
  lm(percprof ~ percollege, data = .) %>%
  broom::augment() %>%
  print()

# plot residuals as vertical line segments
ggplot(regdata, aes(percollege, percprof)) +
  geom_linerange(aes(ymin = .fitted, ymax = .fitted + .resid),
                 color = "red") +
  geom_point(shape = 21, fill = "gray") +
  geom_line(aes(y = .fitted)) +
  labs(x = "Percent w/ College Degree",
       y = "Percent w/ Prof. Degree",
       title = "Wisconsin Counties Only")



# ---- simpler regression example -----------------------

linreg <- lm(percprof ~ percollege, data = midwest)

linreg



# getting just the coefficients
coef(linreg)

# a data frame of coefficients and statistical output
broom::tidy(linreg)

# hand-draw the regression line compared to geom_smooth
ggplot(midwest, aes(percollege, y = percprof)) +
  geom_point(color = "gray") +
  geom_smooth(method = "lm", se = FALSE) +
  geom_abline(intercept = coef(linreg)[1],
              slope = coef(linreg)[2],
              color = "red")



# generate predicted values using augment()
preds <- broom::augment(linreg) %>%
  print()


# residuals vs. fits
# good model shows no patterns in the residuals
ggplot(preds, aes(x = .fitted, y = .resid)) +
  geom_point() +
  geom_hline(yintercept = 0) 

# we probably have more pattern than we'd like

