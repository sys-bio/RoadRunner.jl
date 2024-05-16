using SafeTestsets


@safetestset "antimony test 0" begin include("antimony_test_0.jl") end

@safetestset "antimony test 1" begin include("antimony_test_1.jl") end

@safetestset "antimony test 2" begin include("antimony_test_2.jl") end

@safetestset "antimony test 3" begin include("antimony_test_3.jl") end

@safetestset "antimony test 4" begin include("antimony_test_4.jl") end

@safetestset "antimony test 5" begin include("antimony_test_5.jl") end

@safetestset "antimony test 6" begin include("antimony_test_6.jl") end

@safetestset "antimony test 7" begin include("antimony_test_7.jl") end

@safetestset "antimony test 8" begin include("antimony_test_8.jl") end

@safetestset "sbml test" begin include("sbml_test.jl") end

@safetestset "error test" begin include("error_test.jl") end
