using RoadRunner
using Test


@testset "error test" begin

    # Test that antimony errors are using the getLastAntimonyError function
    bad_antimony = "A -> B; k1*A, A=10,"
    @test_throws ErrorException("Error in model string, line 1:  syntax error, unexpected ',', expecting end of line or ';' or '\\n'") RoadRunner.loada(bad_antimony)

    # Test that roadrunner errors are using the getLastError function from the RoadRunner.jl module
    test_antimony = "A -> B; k1*A; A=10; k1=5"
    r = RoadRunner.loada(test_antimony)
    @test_throws ErrorException("RoadRunner exception: No sbml element exists for symbol 'S'\n") RoadRunner.getValue(r, "S")
    
end