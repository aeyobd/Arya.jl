import TOML
import Colors: Colorant
import ColorSchemeTools: make_colorscheme


struct SmartMinorTicks end

const UNITS_PER_INCH = 72
const HW_RATIO = 3/4


COLORS = Makie.wong_colors()

const DefaultLinearTicks = WilkinsonTicks(5,
	Q = [(1.0, 1.0), (5.0, 0.9), (2.0, 0.7)]
)


function theme_arya(; width=3.25, fontsize=12)
    arya = Theme(
        px_per_unit=5, # controls resolution for rasterization
        pt_per_unit=1, # 1 unit = 1 pt, so 1 inch = 72 units = 72*px_per_unit pixels
        size = figsize_from_inches(width),
        colormap=get_arya_cmap(),
        fonts = (;
            regular = Makie.texfont(:regular),
            bold = Makie.texfont(:bold),
            italic =  Makie.texfont(:italic),
            bold_italic =  Makie.texfont(:bolditalic),
            ),
        fontsize = fontsize,
        Axis = (; 
            xticks = DefaultLinearTicks,
            yticks = DefaultLinearTicks,
            xtickwidth = 1,
            ytickwidth = 1,
            xticklength = 10/3,
            yticklength = 10/3,
            xminorticksvisible = true,
            yminorticksvisible = true,
            xminorticks = SmartMinorTicks(),
            yminorticks = SmartMinorTicks(),
            xminortickwidth = 0.5,
            yminortickwidth = 0.5,
            xminorticklength = 5/3,
            yminorticklength = 5/3,
            xticksmirrored = true,
            yticksmirrored = true,
            xtickalign = 1,
            xminortickalign = 1,
            ytickalign = 1,
            yminortickalign = 1,
            xgridvisible = false,
            ygridvisible = false,
            make_font_settings(fontsize=fontsize)...
        ),

        CairoMakie = (; px_per_unit=5, type="svg"),
        GLMakie = (; px_per_unit=5)

    )

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
    update_theme!( size = figsize_from_inches(width, height))
end


"""
    update_fontsize!(fontsize::Real)

Update the current theme with the given fontsize (in points).
"""
function update_fontsize!(fontsize::Real)
    smallfontsize = round(Int, 0.8*fontsize)
    largefontsize = round(Int, 1.2*fontsize)
    update_theme!(; fontsize=fontsize, Axis = (;make_font_settings(fontsize=fontsize)...))
end

function make_font_settings(;fontsize=12)
    small = floor(Int, 0.8*fontsize)
    large = ceil(Int, 1.2*fontsize)
    medium = fontsize

    return Dict(
        :titlesize=>large,
        :subtitlesize=>large,
        :xlabelsize=>medium,
        :ylabelsize=>medium,
        :xticklabelsize=>small,
        :yticklabelsize=>small,
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
