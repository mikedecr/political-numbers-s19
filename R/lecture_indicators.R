# ----------------------------------------------------
#   Script: Indicators and interactions (March 25)
# ----------------------------------------------------


library("tidyverse")
library("here")
library("broom")





# ---- Confounding -----------------------

# Here is some data:
# - U variable (unobserved)
# - error terms for generating X and Y
confound_data <- 
  tibble(U = rnorm(200, 0, 1),
         error_x = rnorm(200, 0, 1),
         error_y = rnorm(200, 0, 1))


# Create X and Y data
# X = f(U) and Y = f(U)
# but Y ≠ f(X)
confound_data <- confound_data %>%
  mutate(
    X = 2 + (3*U) + error_x, 
    Y = 1 + (2*U) + error_y
  ) %>%
  select(-starts_with("error")) %>%
  print()


# plot the relationship between X and Y
ggplot(data = confound_data, aes(x = X, y = Y)) +
  geom_point() +
  labs(title = "X and Y are not actually related",
       subtitle = "But both are affected by U") +
  theme(axis.text = element_blank(),
        axis.ticks = element_blank())






# ---- Ideology and Election data -----------------------

# House members in most recent Congress (2017-2018) 
# And presidential vote data from 2016
house <- read_csv(here("data", "house-ideology.csv")) %>%
  print()


# estimate the linear model 
# lm(y ~ x, data = dataset)
house_reg <- lm(nominate_dim1 ~ rep_pvote, data = house)

tidy(house_reg, conf.int = TRUE)


# ---- plot the relationship -----------------------

# here's a fun thing:
# let's store "democrat blue" and "republican red" color codes as objects
dblue <- "#259FDD"
rred <- "#FC5E47"

# let's also set the "default" ggplot theme
theme_set(theme_minimal())


# make the plot
ggplot(data = house, aes(x = rep_pvote, y = nominate_dim1)) +
  # axis lines
  geom_hline(yintercept = 0, color = "gray") +
  geom_vline(xintercept = 0.5, color = "gray") +
  # estimated relationship
  geom_smooth(method = "lm", color = "black", size = 0.5) +
  # plot points, white outline, party-color fill
  geom_point(color = "white", shape = 21,
             aes(fill = party),
             show.legend = FALSE) +
  # override default color scale
  scale_fill_manual(values = c("Democrat" = dblue, "Republican" = rred)) +
  # axis labels
  labs(x = "District GOP Presidential Vote", y = "NOMINATE Score") +
  # x and y axis limits
  coord_cartesian(xlim = c(0, 1), ylim = c(-1, 1)) +
  # express X labels as percents
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  # little bonus
  # text labels along the X and Y axes
  annotate(geom = "text", x = 0.25, y = -1, vjust = 0,
           label = "Democratic Districts", family = "Source Sans Pro",
           color = dblue) +
  annotate(geom = "text", x = 0.75, y = -1, vjust = 0,
           label = "Republican Districts", family = "Source Sans Pro",
           color = rred) +
  annotate(geom = "text", x = 0, y = -0.5, angle = 90,
           label = "Liberal\nMembers", family = "Source Sans Pro",
           color = dblue) +
  annotate(geom = "text", x = 0, y = 0.5, angle = 90,
           label = "Conservative\nMembers", family = "Source Sans Pro",
           color = rred) 




# ---- Controlling for party (with a dummy variable) -----------------------

# new_variable = case_when(if condition ~ result if TRUE,
#                          if condition2 ~ result if TRUE)
house <- house %>%
  mutate(republican = case_when(party == "Republican" ~ 1,
                                party == "Democrat" ~ 0)) %>%
  print()


# translated: is the member a Republican? 1 if yes, 0 if no


# use `+` to add additional predictors to the regression
reg_party <- lm(nominate_dim1 ~ rep_pvote + republican,
                data = house)

tidy(reg_party)


# ---- Bonus lesson on "how well the model fits" -----------------------

# use the glance function to look at model-level summaries

# first model, ideology ~ presvote
glance(house_reg)

# second model, ideology ~ presvote + party
glance(reg_party)


# Compare the adj.r.squared values.
# R^2 is a measure of model fit. 
# It measures the "proportion of the variation in Y" that is explained by X.
# R^2 = 1.0 would be a perfect prediction.
# R^2 = 0 would be a useless prediction.
# Any time you add variables to a model, 
#   you increase R^2 even due to randomness. But "adjusted R^2" is 
#   meant to penalize the inclusion of additional variables. 
#   If adding another variable to the model increases the "adjusted R^2," 
#   then the model is explaining more of Y.
#   As always, "explaining" just means "stronger correlation." 
#   It doesn't tell us about causality.



# ---- Generate model predictions -----------------------

# augment() creates predicted values (yhat)
model_predictions <- reg_party %>%
  augment() %>%
  print()

# plot them along with original data
ggplot(data = house, aes(x = rep_pvote, y = nominate_dim1)) +
  geom_hline(yintercept = 0, color = "gray") +
  geom_vline(xintercept = 0.5, color = "gray") +
  geom_point(color = "white", shape = 21,
             aes(fill = party),
             show.legend = FALSE) +
  scale_fill_manual(values = c("Democrat" = dblue, "Republican" = rred)) +
  labs(x = "District GOP Presidential Vote", y = "NOMINATE Score") +
  coord_cartesian(xlim = c(0, 1), ylim = c(-1, 1)) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  # add model predictions. Specify what we want to use for Y data.
  # we use as.factor(republican) because mapping color to a numeric variable
  #   creates a color gradient by default, and we don't want that.
  #   See what happens if you say aes(color = republican)
  geom_line(data = model_predictions,
            aes(y = .fitted, color = as.factor(republican))) +
  scale_color_manual(values = c("0" = dblue, "1" = rred))



# ---- Multi-category example -----------------------

# car data
mtcars

# cars have 4, 6, or 8 cylinders
count(mtcars, cyl)


# make dummy variables for each cylinder count
mtcars <- mtcars %>%
  mutate(
    four_cyl = case_when(cyl == 4 ~ 1, 
                         cyl != 4 ~ 0), 
    six_cyl = case_when(cyl == 6 ~ 1, 
                        cyl != 6 ~ 0), 
    eight_cyl = case_when(cyl == 8 ~ 1, 
                          cyl != 8 ~ 0)
  ) %>%
  print()


# but when we do the car model, we have to leave a category omitted
car_model <- lm(mpg ~ six_cyl + eight_cyl, data = mtcars)

tidy(car_model)

# generate model predictions
# augment() the model
# since all 4, 6, and 8 cylinder cars have the same prediction in the model,
# let's just reduce the data using summarize()
car_data <- car_model %>%
  augment() %>%
  group_by(six_cyl, eight_cyl) %>%
  summarize(fitted = unique(.fitted)) %>% 
  print()

# omitted category is 4 cylinders
# when six_cyl == 0 and eight_cyl == 0, that car has 4 cylinders 
# coefficients of car_model show the *difference* in mpg compared to 4 cyl





# ---- Dummies for VARYING SLOPES (Interaction terms) --------------


# create interaction term: (pvote * republican)
house <- house %>%
  mutate(interact_vote_rep = rep_pvote * republican) %>%
  print()


# estimate the model
interact_reg <- 
  lm(nominate_dim1 ~ rep_pvote + republican + interact_vote_rep, 
     data = house)

# view results
tidy(interact_reg)

# coefficients mean:
# (Intercept): intercept (when republican == 0)
# rep_pvote: slope on presidential vote (when republican == 0)
# republican: intercept shift compared to republican == 0
# interact_vote_rep: slope shift compared to republican == 0


# generate model predictions
interact_predictions <- interact_reg %>%
  augment() %>%
  print()


# plot predicted values over the original data

ggplot(data = house, aes(x = rep_pvote, y = nominate_dim1)) +
  geom_hline(yintercept = 0, color = "gray") +
  geom_vline(xintercept = 0.5, color = "gray") +
  labs(x = "District GOP Presidential Vote",
       y = "NOMINATE Score") +
  coord_cartesian(xlim = c(0, 1),
                  ylim = c(-1, 1)) +
  scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
  geom_point(color = "white", shape = 21,
             aes(fill = party),
             show.legend = FALSE) +
  scale_fill_manual(values = c("Democrat" = dblue,
                               "Republican" = rred)) +
  geom_line(data = interact_predictions,
            aes(y = .fitted, color = as.factor(republican))) +
  scale_color_manual(values = c("0" = dblue, "1" = rred))

