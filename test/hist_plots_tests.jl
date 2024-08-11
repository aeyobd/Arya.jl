using Arya
import Makie


@testset "making plot" begin
    x = rand(100)
    y = rand(100)

    p = Arya.hist2d(x, y)
    @test p isa Makie.FigureAxisPlot

end
