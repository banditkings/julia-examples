# This is a quickstart template to work on tidy tuesday projects in Julia
using RCall, DataFramesMeta, Statistics;
# Plotting Functions - Gadfly
using Gadfly;
Gadfly.push_theme(:dark)
set_default_plot_size(18cm, 18cm)

# Plotting Functions - Makie
# using CairoMakie, ColorSchemes;
# set_theme!(theme_ggplot2())

YEAR=2022;
WEEK=13;

# TidytuesdayR
tt_data = R"tt_data <- tidytuesdayR::tt_load($YEAR, week=$WEEK)";

# R --> Julia
df= rcopy(tt_data["sports"])

describe(df)

@chain df begin
    head
end

