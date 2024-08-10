
include("setup.jl")


tests = []

for test in tests
    @testset "$test" begin
        include("$(test)_tests.jl")
    end
end
