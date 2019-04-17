# ----------------------------------------------------
#   Multiple regression in R
# ----------------------------------------------------

library("tidyverse")
library("broom") # for model output!



# ---- Regression review -----------------------

# Using midwest county data.
# Estimate pct professional degree as f(pct college degree)

ed_mod <- lm(percprof ~ percollege, data = midwest)

# results
ed_mod

# yhat = a + bx
# yhat = (-1.7899) + (0.3413)x


# We can look at more model output using tidy()
tidy(ed_mod)

# columns
# - estimate: the estimated intercept or slope
# - std.error: the uncertainty of that slope
# - statistic: estimate / std.error. 
#     This is a "standardized slope" that puts all slopes on the same scale. 
#     This is what gets compared to the normal distribution to see if 
#     the slope is "unlikely" or not
# - p.value: the probability of getting a "more extreme" slope by change
#     ...if we assume the TRUE slope is zero


# we can add confidence intervals to our estimate of the slope
tidy(ed_mod, conf.int = TRUE)

# which is like, "my estimate is the `estimate` value,
#   but I'm 95% confident that the TRUE slope 
#   is between `conf.low` and `conf.high`"




# results from tidy() can be piped into other useful functions
# since it gives us a data frame!

# In this example, I just change the names of the terms
#   to make it more readable
tidy_mod <- broom::tidy(ed_mod, conf.int = TRUE) %>%
  mutate(term = case_when(term == "(Intercept)" ~ "Intercept",
                          term == "percollege" ~ "Pct. College")) %>%
  print()



# Here is that gregression as a scatter plot.
ggplot(midwest, aes(x = percollege, y = percprof)) +
  geom_point(color = "gray", shape = 1) +
  geom_smooth(method = "lm", size = 0.5, color = "black", fill = "steelblue") +
  labs(x = "Percent w/ College Degree",
       y = "Percent w/ \nProfessional Degree",
       caption = "Shaded area is 95% confidence interval") +
  theme_bw()

# geom_smooth() with method = "lm" gives us the estimated linear fit
# the black line is the estimated yhat!



# I can calculate predicted values from the regression using augment()
augment(ed_mod)

# the variable `.fitted` is the yhat prediction
# (other variables can be learned about using ?augment)



# I can calculate confidence intervals for yhat 
#   by doing augment() and then calculating yhat +/- the margin of error,
#   where the MOE is 1.96 * .se.fit (the standard error of the prediction)

ed_predictions <- augment(ed_mod) %>%
  mutate(MOE = 1.96 * .se.fit,
         conf.high = .fitted + MOE,
         conf.low = .fitted - MOE) %>%
  print()





# Just to show you that these predictions are valid,
#   I'm going to plot them next to the plot we just made

# this is going to start with the original plot,
# and then it will add my predictions as red lines.
ggplot(midwest, aes(x = percollege, y = percprof)) +
  geom_point(color = "gray", shape = 1) +
  geom_smooth(method = "lm", size = 0.5, color = "black", fill = "steelblue") +
  labs(x = "Percent w/ College Degree",
       y = "Percent w/ \nProfessional Degree",
       caption = "Shaded area is 95% confidence interval") +
  theme_bw() +
  # add augment() predictions
  geom_line(data = ed_predictions, aes(x = percollege, y = .fitted),
            color = "red", linetype = "dashed") +
  geom_line(data = ed_predictions, aes(x = percollege, y = conf.high),
            color = "red", linetype = "dotted") +
  geom_line(data = ed_predictions, aes(x = percollege, y = conf.low),
            color = "red", linetype = "dotted")









# ---- multiple regression example using "car" data -----------------------

# here is original car data
mtcars


# Let's save only a subset and make it neater
car_data <- mtcars %>% 
  as_tibble(rownames = "model") %>%
  select(model, mpg, wt, disp) %>%
  print()




# multiple regression using lm()
# add independent variables with `+`
car_model <- lm(mpg ~ wt + disp, data = car_data)

# look at the results
tidy(car_model, conf.int = TRUE)

# now we have an intercept AND  more than one independent variable!

# yhat = a + (b1*wt) + (b2*disp)
# yhat = 35.0 + (-3.35*wt) + (-0.0177*disp)




# ---- predicted values from multiple regression-----------------------

# When we make predicted values from a multiple regression,
#   we typically want to show how y changes when we vary JUST ONE variable
#   while we "hold others constant."
# This "isolates" the effect of the variable that we are changing.
# We do this by generally holding other variables at their MEANS


# Here I'm making a data frame that starts with the original data
# but I'm instead going to hold `disp` at its mean value

vary_wt <- car_data %>%
  select(mpg, wt, disp) %>%
  mutate(disp = mean(disp)) %>%
  print()

# notice that `disp` is the same, regardless of `wt`


# Remember, the augment() function generates predicted values from the model.
# By default, it uses the data that the model was estimated with
augment(car_model)



# but I can also make model predictions by giving augment() new data.
# Meaning: what would yhat be for this combination of `wt` and `disp`

# do this using augment(model_name, newdata = custom_data)

augment(car_model, newdata = vary_wt)

# I am going to save these results and calculate confidence intervals
wt_predictions <- 
  augment(car_model, newdata = vary_wt) %>%
  mutate(MOE = 1.96 * .se.fit,
         lower_bound = .fitted - MOE,
         upper_bound = .fitted + MOE) %>%
  print()


# now I'll plot the prediction
# What's the partial effect `wt`, while holding `disp` constant at its mean?
# plot the confidence interval as a shaded area using geom_ribbon()

ggplot(wt_predictions, aes(x = wt, y = .fitted)) +
  geom_ribbon(aes(ymin = lower_bound, ymax = upper_bound),
              fill = "skyblue") +
  geom_line() +
  labs(x = "Weight",
       y = "Predicted MPG",
       caption = "Displacement held constant at its mean value")

