using Arya
import Makie

@testset "making plot" begin
    x = rand(100)
    y = rand(100)
    xerr = rand(100)
    yerr = rand(100)


    p = Arya.errscatter(x, y)
    @test p isa Makie.FigureAxisPlot


    p = Arya.errscatter(x, y, xerr=xerr, yerr=yerr)
    @test p isa Makie.FigureAxisPlot

    p = Arya.errscatter(x, y, yerr=yerr)
    @test p isa Makie.FigureAxisPlot

    p = Arya.errscatter(x, y, xerr=xerr)
    @test p isa Makie.FigureAxisPlot
end
