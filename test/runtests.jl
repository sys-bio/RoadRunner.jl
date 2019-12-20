using RoadRunner
using Test
using Plots

rr = RoadRunner.createRRInstance()

ant_str = """
    const Xo, X1
     Xo -> S1; k1*Xo - k2*S1
     S1 -> S2; k3*S2
     S2 -> X1; k4*S2

     Xo = 1;   X1 = 0
     S1 = 0;   S2 = 0
     k1 = 0.1; k2 = 0.56
     k3 = 1.2; k4 = 0.9
"""

rr = loada(ant_str)
data = simulate(rr, 0, 10, 51)
plotSimulation(data, rr)


# speciesName = getFloatingSpeciesIds(rr)
# time = data[:, 1]
# plot(time, data[:, 2:end], label = speciesName)
# RoadRunner.freeRRInstance(rr)

# @testset "RoadRunner.jl" begin
#     ssValues = RoadRunner.computeSteadyStateValues(rr)
#     sol = [0.178571429, -4.38678616e-27]
#     diff = ssValues - sol
#     @test abs(diff[1]) < 1e-7 && abs(diff[2]) < 1e-7
# end
