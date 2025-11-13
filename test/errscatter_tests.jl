using Arya
import Makie

@testset "making plot" begin
    x = rand(100)
    y = rand(100)
    xerr = rand(100)
    yerr = rand(100)


    p = Arya.errorscatter(x, y)
    @test p isa Makie.FigureAxisPlot


    p = Arya.errorscatter(x, y, xerror=xerr, yerror=yerr)
    @test p isa Makie.FigureAxisPlot

    p = Arya.errorscatter(x, y, yerror=yerr)
    @test p isa Makie.FigureAxisPlot

    p = Arya.errorscatter(x, y, xerror=xerr)
    @test p isa Makie.FigureAxisPlot
end
