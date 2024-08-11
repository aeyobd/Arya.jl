
include("setup.jl")


tests = ["hist_plots", "errscatter"]

for test in tests
    @testset "$test" begin
        include("$(test)_tests.jl")
    end
end
