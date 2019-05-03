# ----------------------------------------------------
#   Calculate my PS-270 grade, using R code
# ----------------------------------------------------

# You guessed it...
library("tidyverse")

# but also
library("scales")

# ---- Here is the "master frame" -----------------------

# This code creates a dataset of your grades

# Enter grades by replacing `NA` with assignment grades, 
#   then execute the code.

# Enter grades as values between 0 and 100! 
#   example: if I got an 80% on Essay 1, 
#            I would replace the corresponding NA with 80.

assignments <- 
  tribble(
    ~ assignment,        ~ weight,  ~ grade,
    "Essay 1",               0.15,       96,    
    "Essay 2",               0.15,       NA,    
    "Ex 1",                  0.10,       93,    
    "Ex 2",                  0.10,       NA,    
    "Proj: Question",        0.05,       NA,
    "Proj: Data",            0.10,       NA,
    "Proj: Presentation",    0.05,       NA,
    "Proj: Paper",           0.30,       NA
  ) %>%
  print()

# Review output to verify that grades are entered correctly

# If you want to know what this code is doing, here's the idea:
#   - tribble() create a data frame, row-by-row
#   - Top row: the tilde says "Here's a variable name",
#   - Other rows: supplying data for each row
#   - Indentation affects the appearance but not the performance of the code




# ---- Calculate weighted grade -----------------------

# Now that you've entered your assignment grades,
#   you can find your final grade.

# The code below does the following:
# 1. remove ungraded assignments (filter)
# 2. Weight the grade for each assignment (mutate)
# 3. calculate grade percentage (summarize)
#   - how many (weighted) pts do I have so far?
#   - how many (weighted) pts am I eligible for?
#   - what's the overall percentage?

# don't modify this IN ANY WAY:
assignments %>%
  filter(is.na(grade) == FALSE) %>%
  mutate(weighted = grade * weight) %>%
  summarize(
    my_points = sum(weighted), 
    eligible_points = 100 * sum(weight), 
    grade_so_far = percent(my_points / eligible_points), 
    letter = 
      case_when(
        grade_so_far > 93 ~ "A", 
        grade_so_far < 93 & grade_so_far >= 88 ~ "AB",
        grade_so_far < 88 & grade_so_far >= 83 ~ "B",
        grade_so_far < 83 & grade_so_far >= 78 ~ "BC",
        grade_so_far < 78 & grade_so_far >= 70 ~ "C",
        grade_so_far < 70 & grade_so_far >= 60 ~ "D",
        grade_so_far < 60 ~ "F"
      )
    )



# Final grade should be a percentage



# --- Notes ---

# > if you get an error that says 'invalid 'nsmall' argument',
#   it means you haven't saved your grades into the 'assignments' object
