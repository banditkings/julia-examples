cyberpunk_theme = Theme(
        # teal/cyan, pink, yellow, matrix green, red, violet
        palette = (color =["#08F7FE", "#FE53BB", "#F5D300", "#00ff41", :red, "#9467bd"],),
        backgroundcolor = "#212946",
        textcolor=:gray90,
        resolution=(640,320),
        fontsize=12,
        font = "Arial",
        colormap = :cool,
        cycle = Cycle([:color]),
        Axis = ( 
            backgroundcolor = "#212946",
            topspinevisible = false,
            rightspinevisible = false,
            xgridcolor = "#2A3459",
            ygridcolor = "#2A3459",
            bottomspinecolor = "#2A3459",
            leftspinecolor = "#2A3459",
            ytickcolor = "#2A3459",
            xtickcolor = "#2A3459",
            titlesize=16,
            yautolimitmargin=(0.05, 0.1), # Leaves room for label text
            ),
        Legend = (
            bgcolor = "#212946",
            framecolor = "#2A3459",
        ),            
        # Note in order to apply specific settings to plot types we need to use the Struct/type
        # so to theme barplots() you need to use the BarPlot type
        Lines = (
            linewidth=2,),
        BarPlot = (
            cycle=Cycle([:color]), # Interesting that I have to put it here
            label_size=12,
        )
)
