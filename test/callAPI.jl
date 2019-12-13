using RoadRunnerJulia
#println("in the callAPI file: ", rrlib)

RoadRunnerJulia.setConfigInt("LOADSBMLOPTIONS_CONSERVED_MOIETIES", 1)
#rrlib = Libdl.dlopen("C:/vs_rebuild/install/roadrunner/bin/roadrunner_c_api.dll")
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
println(RoadRunnerJulia.getConfigInt("LOADSBMLOPTIONS_CONSERVED_MOIETIES"))
RoadRunnerJulia.setConfigInt("sfds", 1)
println(RoadRunnerJulia.getConfigInt("sfds"))
data = simulate(rr, 0, 50, 51)
println(data)
ss = steadyState(rr)
println("this is the steady state value: ", ss)
ssValues = RoadRunnerJulia.computeSteadyStateValues(rr)
# str = RoadRunnerJulia.getListOfConfigKeys()
ids = getFloatingSpeciesIds(rr)
#data = RoadRunnerJulia.simulate(rr)
#println(data)
