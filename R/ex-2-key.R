# ----------------------------------------------------
#   Exercise 2: Wisconsin Recount
# ----------------------------------------------------


# ---- 4. LOAD PACKAGES AND PREP -----------------------

library("tidyverse")

library("here")

# --- DIGRESSION: Some more explanation of {here} ---
# When you load the {here} package, it tells you where 'here' is.
# If you are properly in your ps-270 'project' in Rstudio, here()
#   should tell you the 'folder pathway' to your project folder.
here()

# Why does this matter?
# In order to import external data into R, we need to know the "path" to 
#   each file.
# A file path is the sequence of folders you need to navigate to find a file.
# e.g. here is the path to my PS-270 folder.
#   "/Users/michaeldecrescenzo/Box Sync/teaching/270-numbers-S19"
# It means that the folder is in the account on my computer called 
#   "michaeldecrescenzo", but then you have to go into the "Box Sync" folder,
#   then into the "teaching" folder, and so on.
#   
# File "pathways" have always been a pain, for two big reasons. 
# 1) Everybody's computer folders are set up in different ways, based on
#      their personal preferences.
#    The path you would take to find MY PS-270 folder is different from the
#      path you would take to get to YOUR PS-270 folder.
#    We use the project system in Rstudio because it drastically reduces
#      the complexity of navigating everybody's different folder pathways.
#    By always treating the project folder as the "starting point" 
# 2) More on the technical side, different operating systems have some 
#      different rules for writing paths.
#    Some systems use forward slashes to separate folders, while others use
#      backslashes, and so on. It's complicated.
#    When we build paths with here(), it will always use the correct rules
#      regardless of what computer you are using. Nice! 
# 
# To get more of a feel for how here() works, compare what you get when 
#   you type here() vs. here("data"), and so on
here()
here("data")
here("data/some-file-in-my-data-folder.csv")

# here() simplifies the process of building paths because it works like...
#   "Always assume that I'm starting at the top of my project,
#    and then take my into the project's sub-folders to look for files"



# ---- 5. READ DATA INTO R -----------------------

# here() builds the pathway to my data file, starting from my project folder.

wi_raw <- read_csv(here("data", "ex-2-data-key.csv")) %>%
  select(-starts_with("X")) %>%
  print()

# select() keeps variables. 
# I can drop variables by using a minus sign.
# I use the "select helper" function called starts_with() to say
#   "every variable that starts with 'X'".
# So the command says "Drop every variable that starts with 'X'",
#   since Excel thought we wanted to keep those empty columns
#   that used to have stuff in them.

# So in total, this pipe chain says, in order
# 1. Create an object `wi_raw`, it contains...
# 2. The data file (read_csv()) 
#    that lives in this location, relative to my project folder (here())
# 3. Then, drop every variable that starts with "X"
# 4. Then print() out what the results are






# ---- 6. TWO-PARTY VOTE -----------------------

# This chain says:
# 1. Create a new object called `wi`
# 2. It starts with the `wi_raw` data, then
# 3. Add new variables (mutate())
#    - Republican vote % on election night
#    - Republican vote % with updated vote
#    - a logical (TRUE/FALSE) variable that indicates Waukesha
#    - a dummy (binary/indicator) variable that indicates Waukesha,
#        which is just another way of doing the same thing.
# 4. Keep only a subset of the original data 
#    (county, vote percentages, and waukesha indicators)
#    Notice I use another "select helper" function to select any variable that 
#    contains "rep_vote" in its name!

wi <- wi_raw %>%
  mutate(
    rep_vote_enight = prosser_election_night / 
                      (prosser_election_night + kloppenburg_election_night),
    rep_vote_recount = prosser_updated / 
                       (prosser_updated + kloppenburg_updated),
    is_waukesha = (county == "Waukesha"),
    wauk_dummy = case_when(county == "Waukesha" ~ 1,
                           county != "Waukesha" ~ 0)
  ) %>%
  select(county, contains("rep_vote"), is_waukesha, wauk_dummy) %>%
  print()


# Bonus: compare is_waukesha to wauk_dummy to see if they're identical.
wi %>%
  count(is_waukesha, wauk_dummy)

# every FALSE should be 0 (n = 71 of those cases)
# every TRUE should be 1 (n = 0 of those cases)



# ---- 7. PLOT BEFORE-AFTER -----------------------

# let's build this incrementally

# first I include points and the 45° line
# If before and after are identical, they fall on the line
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point()

# notice I don't use aes() to color the abline
# that's because I'm not setting the color according a variable in the data!


# I color the point for Waukesha using the indicator variables
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point(aes(color = is_waukesha))


# Let's hide the legend and make a label
# here's a label that we place ourselves using annotate()
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point(aes(color = is_waukesha),
             show.legend = FALSE) +
  annotate(geom = "text", x = 0.65, y = 0.74, label = "Waukesha")


# here's a label that we place using the underlying x/y data and geom_text
# Because we only want to plot the county name for Waukesha,
#   we want to filter the rest of the counties.
# We need to re-specify the data for the text geom.
# The x and y data are assumed to be the same variable names as ggplot()
#   which is convenient.
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point(aes(color = is_waukesha),
             show.legend = FALSE) +
  geom_text(data = filter(wi, county == "Waukesha"),
            aes(label = county))

# This prints the county name at the X/Y coordinate
# we can "push" the label a little bit using a nudge_ argument
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point(aes(color = is_waukesha),
             show.legend = FALSE) +
  geom_text(data = filter(wi, county == "Waukesha"),
            aes(label = county),
            nudge_x = -0.05)

# nudge_x says nudge the geom .05 x-units to the left.
# nudge_y also exists and works the same way! 


# Let's make this plot prettier and call it done.
ggplot(wi, aes(x = rep_vote_enight, y = rep_vote_recount)) +
  geom_abline(color = "gray") +
  geom_point(aes(color = is_waukesha),
             show.legend = FALSE) +
  geom_text(data = filter(wi, county == "Waukesha"),
            aes(label = county),
            nudge_x = -0.05) +
  labs(title = "How much did Waukesha's \"found votes\" matter?",
       subtitle = "Data from each county in WI",
       x = "Prosser Vote, Election Night",
       y = "Prosser Vote, Final Tally") +
  scale_color_brewer(palette = "Dark2") +
  scale_x_continuous(labels = scales::percent) +
  scale_y_continuous(labels = scales::percent) +
  theme_bw()

ggsave(here("figures", "exercise-02-plot-solution.pdf"),
       height = 4, width = 6)

# Some tricks I did:
# Print quote marks within a string by "escaping" them w/ a backslash
# Scale functions to modify default aesthetics
# - I changed the color pallete
# - I changed the x and y labels to print as percentages! (This only works
#     when your original data are proportions, so heads up)


# ---- 8. CONCLUSION -----------------------

# the found votes didn't change Waukesha's results that much



