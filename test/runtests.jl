
include("setup.jl")


tests = ["limits", "histogram", "interface", "bayesian_blocks"]

for test in tests
    @testset "$test" begin
        include("$(test)_tests.jl")
    end
end
