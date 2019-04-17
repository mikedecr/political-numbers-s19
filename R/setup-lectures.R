
library("knitr")
library("here")
library("magrittr")
library("tidyverse")
library("ggplot2")
library("scales")
library("latex2exp")

# ggtheme?
# source(here("R/theme_mathcamp.R"))

# set default theme
theme_set(
  ggthemes::theme_base(base_family = "Source Sans Pro") + 
  theme(text = element_text(family = "Source Sans Pro"),
        plot.background = element_blank(),
        axis.ticks.length = unit(0.25, "lines"))
) 


# suppress version on html output folders
options(htmltools.dir.version = FALSE)


# colors to match the slides and graphics
primary <- "#e65c00"
secondary <- "#0479a8"
# primary <- "#006747"
# secondary <- "#CFC493"
# secondary <- "#002b36"

# Xaringan settings

library("xaringan")
library("xaringanthemer")

serif_font <- "Minion Pro"
sans_font <- "PT Sans"
code_font <- "Consolas"

duo_accent(primary_color = primary, 
           secondary_color = secondary, 
           # header_font_google = google_font("Roboto Slab"), 
           # text_font_google = google_font("Roboto"),
           # code_font_google = google_font("Roboto Mono"),
           header_font_family = serif_font,
           # text_font_family = "Myriad Pro",
           text_font_google = google_font(sans_font),
           code_font_family = code_font, 
           code_inline_background_color    = "#F5F5F5",
           table_row_even_background_color = "#F5F5F5",
           extra_css = 
             list(".remark-slide-number" = list("display" = "none"),
                  ".remark-inline-code" = list("color" = "black",
                                               "background" = "#F5F5F5",
                                                #e7e8e2; /* darker */
                                               "border-radius" = "3px",
                                               "padding" = "4px"),
                  ".title-slide, .title-slide h1, .title-slide h2, .title-slide h3" = list("font-family" = "PT Sans",
                                             # "font-family" = "Myriad Pro",
                                             "font-style" = "normal", 
                                             "color" = "white",
                                             "font-weight" = "normal"),
                  ".left-code" = list("width" = "38%",
                                      "height" = "92%",
                                      "float" = "left"),
                  ".right-plot" = list("width" = "60%", 
                                       "float" = "right", 
                                       "padding-left" = "1%")))

# use webshot() to save as PDF