
x = [-0.2, 0.1, -0.546, π, 3, 1.56, 20.75, NaN, Inf, -Inf]
x_min = -0.546
x_max = 20.75

@testset "no limits" begin
    limits = Arya.calc_limits(x)
    @test limits[1] == x_min
    @test limits[2] == x_max


    limits = Arya.calc_limits(x, nothing)
    @test limits[1] == x_min
    @test limits[2] == x_max


    limits = Arya.calc_limits(x, (nothing, nothing))
    @test limits[1] == x_min
    @test limits[2] == x_max
end

@testset "only upper" begin
    for up in [-1, 2, 50, Inf, -Inf, NaN]
        limits = Arya.calc_limits(x, (nothing, up))
        @test limits[1] == x_min
        @test limits[2] === up
    end
end


@testset "only lower" begin
    for lower in [-1, 2, 50, Inf, -Inf, NaN]
        limits = Arya.calc_limits(x, (lower, nothing))
        @test limits[1] === lower
        @test limits[2] == x_max
    end
end




y = [0.2, 0.4, -0.2, 2π, -4, 1.56, 9.75, NaN, Inf, -Inf]
y_min = -4
y_max = 9.75

@testset "both limits" begin
    xlims, ylims = Arya.calc_limits(x, y)
    @test xlims[1] == x_min
    @test xlims[2] == x_max
    @test ylims[1] == y_min
    @test ylims[2] == y_max

end
