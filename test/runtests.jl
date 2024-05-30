
include("setup.jl")


tests = ["limits", "histogram"]

for test in tests
    @testset "$test" begin
        include("$(test)_tests.jl")
    end
end
