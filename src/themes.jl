import TOML
import Colors: Colorant
import ColorSchemeTools: make_colorscheme


"A type allowing for minor ticks to be automatically generated in a sensable way"
struct SmartMinorTicks end

struct SmartMajorTicks end

const UNITS_PER_INCH = 72
const HW_RATIO = 3/4


const COLORS = parse.(Colorant, ["#0173b2ff", "#de8f05ff", "#029e73ff", "#d55e00ff", "#cc78bcff", 
                                 "#ca9161ff", "#fbafe4ff", "#949494ff", "#ece133ff", "#56b4e9ff"])

const DefaultLinearTicks = WilkinsonTicks(5,
	Q = [(1.0, 1.0), (5.0, 0.9), (2.0, 0.7)],
        k_min = 3,
)


function theme_arya(; width=3.25, fontsize=12, px_per_unit=4, pt_per_unit=1)
    # for a 12pt font size in the times font,
    # the em dash is 12 pt long and 0.6 pt high
    # the recommended minimum element size is 0.3 pt. 
    # So we can make major ticks 0.6 pt and minor 0.3 pt
    # but I default to make the minor tick labels in 10 pt font
    # Thus, we can use double width and single width elements for tick labels
    # and lengths of 

    smallfontsize = round(Int, 0.8*fontsize)
    
    x = smallfontsize / 12
    lw = x 
    slw = 2/3 * x
    padding = 3x

    # full cycle of markers x colors

    hollowmarkers = [false, false, false, false,
                     true, true, true, false]
    markers = [:circle, :rect, :utriangle, :star5, 
               :diamond, :pentagon, :dtriangle, :xcross]
    @assert length(hollowmarkers) == length(markers)

    Nmarker = length(markers)
    Ncolor = length(COLORS)
    markercolors = repeat(COLORS, Nmarker)
    hollowmarkers = repeat(hollowmarkers, Ncolor)
    transparent = RGBAf(0.0, 0.0, 0.0, 0.0)

    # Making hollow markers by setting the marker face color to transparent
    markerstrokecolors = copy(markercolors)
    N = 0
    for i in eachindex(markercolors)
        hollowmarkers[i] && (markercolors[i] = transparent)
    end

    markerstrokewidth = slw .* hollowmarkers

    scattercycle = Cycle(
        [
         :marker => :marker, 
         :color => :markercolor, 
         :strokecolor => :markerstrokecolor,
         :strokewidth => :markerstrokewidth,
        ], covary = true)

    linecycle = Cycle(
        [
         :color=>:color, 
         :linestyle=>:linestyle,
        ], covary = true)
    cycle = Cycle([:color])

    arya = Theme(
        px_per_unit = px_per_unit, # controls resolution for rasterization
        pt_per_unit = 1, # units are points so 72 units / inch.
        figure_padding = 2padding,
        linewidth = lw,
        markersize = 6lw,
        markerstrokewidth = 0,
        patchstrokewidth = 0,
        size = figsize_from_inches(width),
        colormap=get_arya_cmap(),
        rowgap = smallfontsize,
        colgap = 18x,
        fontsize = fontsize,
        palette = (;
            color = COLORS,
            patchcolor = COLORS,
            linestyle = [nothing, :dash, :dot, :dashdot, :dashdotdot],
            markercolor = markercolors,
            marker = markers,
            markerstrokecolor = markerstrokecolors,
            markerstrokewidth = markerstrokewidth,
       ),
        fonts = (;
            regular = Makie.texfont(:regular),
            bold = Makie.texfont(:bold),
            italic =  Makie.texfont(:italic),
            bold_italic =  Makie.texfont(:bolditalic),
            ),
        Axis = (; 
            xticks = DefaultLinearTicks,
            yticks = DefaultLinearTicks,
            xtickwidth = lw,
            ytickwidth = lw,
            xticksize = 4x, # xticksize?
            yticksize = 4x,
            xticklabelpad = 2x,
            yticklabelpad = 2x,
            xlabelpad = 3x,
            ylabelpad = 3x,
            xminorticksvisible = true,
            yminorticksvisible = true,
            xminorticks = SmartMinorTicks(),
            yminorticks = SmartMinorTicks(),
            xminortickwidth = slw,
            yminortickwidth = slw,
            xminorticksize = 3x,
            yminorticksize = 3x,
            xticksmirrored = true,
            yticksmirrored = true,
            xtickalign = 1,
            xminortickalign = 1,
            ytickalign = 1,
            yminortickalign = 1,
            xgridvisible = false,
            ygridvisible = false,
            spinewidth = lw,
        ),
        Colorbar = (;
            ticks = DefaultLinearTicks,
            tickwidth = lw,
            ticksize = 3x,
            minorticksvisible = true,
            minorticks = SmartMinorTicks(),
            minortickwidth = slw,
            minorticksize = 1.5x,
            spinewidth = lw,
        ),
        Legend = (;
            padding = (6x, 6x, 6x, 6x),
            patchsize = (12x, 6x),
            framewidth = lw,
            labelsize = smallfontsize,
        ),
        Scatter = (;
            cycle = scattercycle
           ),
        Lines = (;
            cycle = linecycle
           ),
        ErrorScatter = (;
            cycle = cycle
           ),
        CairoMakie = (; 
            type=:png,
            pt_per_unit=1pt_per_unit,
            px_per_unit=2px_per_unit, # for displaying better
            antialias = :best,
        ),
        GLMakie = (; px_per_unit=px_per_unit)

    )

    update_theme!(arya; make_font_settings(fontsize=fontsize)...)

    return arya
end


"""
    figsize_from_inches(width::Real, height::Real=width*HW_RATIO)

Return the size in pixels for a figure with the given width and height in inches.
"""
function figsize_from_inches(width::Real, height::Real=width*HW_RATIO)
    return (width * UNITS_PER_INCH, height * UNITS_PER_INCH)
end


"""
    update_figsize!(width::Real, height::Real=width*HW_RATIO)

Update the current theme with the given width and height in inches.
"""
function update_figsize!(width::Real, height::Real=width*HW_RATIO)
    update_theme!(size = figsize_from_inches(width, height))
end


"""
    update_fontsize!(fontsize::Real)

Update the current theme with the given fontsize (in points).
"""
function update_fontsize!(fontsize::Real)
    update_theme!(; make_font_settings(fontsize=fontsize)...)
end

function make_font_settings(;fontsize::Real=12)
    small = floor(Int, 10/12*fontsize)
    large = ceil(Int, 14/12*fontsize)
    medium = fontsize

    return (
        fontsize = fontsize,
        Axis = (;
            titlesize=large,
            subtitlesize=medium,
            xlabelsize=medium,
            ylabelsize=medium,
            xticklabelsize=small,
            yticklabelsize=small,
       ),
        Legend = (;
            labelsize = small,
            titlesize = medium,
           ),
        Label = (;
            fontsize = medium,
       ),
        Colorbar = (;
            labelsize = medium,
            ticklabelsize = small,
        )
    )
end


"""
    get_arya_cmap()

Return the Arya colormap.
"""
function get_arya_cmap()
    cmap_file = joinpath(@__DIR__, "cmap_arya.toml")
    color_list = parse.(Colorant, TOML.parsefile(cmap_file)["cmap_arya"])
    cmap = make_colorscheme(color_list, length(color_list))
    return cmap
end


function get_tickstep(tickvalues)
    dx = diff(tickvalues)
    if !(all(dx .≈ dx[1]))
        @error "all tick steps must be the same with SmartMinorTicks. Ticks are $tickvalues"
    end

    dx = dx[1]
    place = floor(Int64, log10(abs(dx))) 

    dx = dx * .10^(place)

    for step in [1, 2, 2.5, 3, 5, 10]
        if dx ≈ step atol=1e-6
            return step, place
        end
    end
    @warn "difference $dx not implemented"
    
    return NaN, NaN
end


function get_subdivision(step)
    if step ≈ 1
        return 5
    elseif step ≈ 2
        return 4
    elseif step ≈ 2.5
        return 5
    elseif step ≈ 3
        return 3
    elseif step ≈ 5
        return 5
    elseif step ≈ 10
        return 5
    else
        @error "step $step not implemented"
    end
end


function Makie.get_minor_tickvalues(i::SmartMinorTicks, scale::typeof(identity), tickvalues, vmin, vmax)
    step, _ = get_tickstep(tickvalues)
    subdivision = get_subdivision(step)
    return Makie.get_minor_tickvalues(IntervalsBetween(subdivision), scale, tickvalues, vmin, vmax)
end


function Makie.get_minor_tickvalues(i::SmartMinorTicks, scale::typeof(log10), tickvalues, vmin, vmax)
    step, place = get_tickstep(log10.(tickvalues))
    step = 10. ^ (step * 10. ^ place)
    subticks = []
    
    if step == 10
            subticks = collect(2:9)
    elseif step == 100
            subticks = [10]
    elseif step == 1000
            subticks = [10, 100]
    else
            @error "difference $step not implemennted in log"
    end
    
    expanded_tickvalues = [tickvalues[1]/step; tickvalues; tickvalues[end]*step]

    minor_tick_values = Float64[]
    for i in eachindex(expanded_tickvalues)
        x0 = expanded_tickvalues[i]

        for j in eachindex(subticks)
            x = x0 * subticks[j]
            if (x < vmin) | (x > vmax)
                    #
            else
                    push!(minor_tick_values, x)
            end
        end
    end

    @debug minor_tick_values
    return minor_tick_values
end
