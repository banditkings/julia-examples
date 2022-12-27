# This is a quickstart template to work on tidy tuesday projects in Julia
using RCall, DataFramesMeta, Gadfly, Statistics;
# Plotting Functions - Gadfly
using Gadfly;
Gadfly.push_theme(:dark)
set_default_plot_size(18cm, 18cm)

# Plotting Functions - Makie
# using CairoMakie, ColorSchemes;
# set_theme!(theme_ggplot2())

using TimeSeries

YEAR=2022;
WEEK=15;

# Use tidytuesdayR::tt_load to load the data from Github
tt_data = R"tt_data <- tidytuesdayR::tt_load($YEAR, week=$WEEK)";

# R --> Julia
df = rcopy(tt_data["fuel_access"])
describe(df)

@select!(df, :Entity, :Code, :Year,
         :"Access"=:"Access to clean fuels and technologies for cooking  (% of population)")

# Let's try to filter out to the groups with the bottom 10% of the average Access
num_10 = round(Int, length(unique(df.Entity)) * 0.1)

lowest_entities = @chain df begin
    groupby(:Entity)
    @combine(:avg_access=mean(:Access))
    @orderby(:avg_access)
    first(num_10)
end

@chain df begin
    dropmissing(:Access)
    @rsubset(:Entity ∈ append!(["Afghanistan"], lowest_entities.Entity))
    groupby(:Entity)
    @transform(:avg_access=mean(:Access))
    @orderby(:avg_access, rev=true)
    plot(x=:Entity, y=:Access, color=:Entity, Geom.boxplot, Guide.title("Countries with Lowest Average Access"))
end

@chain df begin
    @rsubset(:Entity ∈ append!(["Nigeria"], lowest_entities.Entity))
    plot(x=:Year, y=:Access, color=:Entity, Geom.line, Guide.title("Country Access over time"))
end

death_timeseries = rcopy(tt_data["death_timeseries"])
@select!(death_timeseries, :Entity, :Code, :Year=:Year___3,
:Deaths = :"Deaths - Cause: All causes - Risk: Household air pollution from solid fuels - Sex: Both - Age: All Ages (Number)___4")

describe(death_timeseries)

@chain death_timeseries begin
    @rsubset(:Entity=="Nigeria")
    plot(x=:Year, y=:Deaths, Geom.line, Guide.title("Deaths (All Causes) over time in Nigeria"))
end

# can we see deaths vs access in the same plot? We should convert it to % change.
death_timeseries.Year |> unique

# Combine the access and deaths dataframes together
df2 = @chain df begin
    leftjoin(death_timeseries, on=[:Entity, :Year], makeunique=true)
    select(Not(:Code_1))
    @rsubset(~isequal(:Deaths, missing))
end

# Actually I found a much easier way to do this, using the transform and 'first'
@chain df2 begin
    @orderby(:Entity, :Year)
    groupby(:Entity)
    @transform(:Access_chg=:Access./first(:Access) .-1, :Deaths_chg=:Deaths./first(:Deaths) .-1)
    select(Not([:Access, :Deaths]))
    stack([:Deaths_chg, :Access_chg])
    @rsubset(:Entity ∈ ["Nigeria", "Haiti", "Afghanistan"])
    plot(x=:Year, y=:value, color=:variable, xgroup=:Entity, Geom.subplot_grid(Geom.line), 
         Guide.title("How do Deaths and Access Change over Time?"))
end
