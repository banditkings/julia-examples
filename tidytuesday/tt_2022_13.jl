# This is a quickstart template to work on tidy tuesday projects in Julia
using RCall, DataFramesMeta, Gadfly;

# Between DataFramesMeta and Gadfly, you can do a very "tidy-esque" workflow

Gadfly.push_theme(:dark)
set_default_plot_size(21cm, 17cm)
ENV["COLUMNS"]=100;
ENV["LINES"]=20;

YEAR=2022
WEEK=13

# TidytuesdayR
data = R"tt_data <- tidytuesdayR::tt_load($YEAR, week=$WEEK)"

# R --> Julia
df= rcopy(data["sports"])

# This dataset comes from the 'Equity in Athletics Data Analysis', from Data is Plural
# So we'll want to make comparisons of sports, colleges, and genders. 

# Let's look at the kinds of sports there are:
@chain df begin
    plot(x=:sports, Geom.histogram,
        Guide.title("Types of Sports"))
end
# Guess that wasn't that informative - let's try something else:

# What about gender differences in certain sports, by total participation?
@chain df begin
    @by(:sports, 
        :difference=(sum(:sum_partic_women) - sum(:sum_partic_men)))
    @rsubset(:sports ∉ ["Football", "Baseball", "Softball"])
    @orderby(:difference)
    plot(x=:sports, y=:difference, 
         Geom.bar, 
         Guide.title("Gender Differences by Sport"))
end
# That just tells us some overall gender differences but that's not as interesting 
# compared to revenues

@chain df begin
    @rsubset(:sports ∉ ["Football"])
    @by([:sports],
        :difference=(sum(skipmissing(:rev_women)) - sum(skipmissing(:rev_men))))
    @orderby(:difference)
    @rsubset(abs(:difference)>1e6)
    plot(x=:difference, y=:sports,
        Geom.bar(orientation=:horizontal),
        Guide.title("Revenue Difference between Men and Women by Sport\nExcluding Football"))
end

names(df)