using RoadRunnerJulia
#println("in the callAPI file: ", rrlib)

RoadRunnerJulia.setConfigInt("LOADSBMLOPTIONS_CONSERVED_MOIETIES", 1)
#rrlib = Libdl.dlopen("C:/vs_rebuild/install/roadrunner/bin/roadrunner_c_api.dll")
ant_str = """
const A, C
A -> B; k1 * A
B -> C; k2 * B
k1 = 0.1; k2 = 0.2
A = 2; B = 0; C = 1;
"""
rr = loada(ant_str)
println(RoadRunnerJulia.getConfigInt("LOADSBMLOPTIONS_CONSERVED_MOIETIES"))
RoadRunnerJulia.setConfigInt("sfds", 1)
println(RoadRunnerJulia.getConfigInt("sfds"))
data = simulate(rr, 0, 50, 51)
println(data)
ss = steadyState(rr)
println("this is the steady state value: ", ss)
str = RoadRunnerJulia.getListOfConfigKeys()
ids = getFloatingSpeciesIds(rr)
#data = RoadRunnerJulia.simulate(rr)
#println(data)
