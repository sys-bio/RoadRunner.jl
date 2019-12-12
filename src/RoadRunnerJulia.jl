module RoadRunnerJulia

__precompile__(false)

export loada
export createRRInstance
export simulate
export getFloatingSpeciesIds
export steadyState


using Libdl
rrlib = Libdl.dlopen("C:/vs_rebuild/install/roadrunner/bin/roadrunner_c_api.dll")
antlib = Libdl.dlopen("C:/Users/lukez/OneDrive/Desktop/Network Generator/Network-Generator/libantimony.dll")
# Libdl.dlopen("C:/vs_rebuild/install/roadrunner/bin/roadrunner_c_api.dll")

# println("this is the value of rrlib outside of the function: ", rrlib)
#a = 1000
#k = Array{Float64}(undef, 100)
include("rrc_utilities_binding.jl")
include("rrc_types.jl")
include("antimony_binding.jl")

# function __init__()
#   global rrlib = Libdl.dlopen("C:/vs_rebuild/install/roadrunner/bin/roadrunner_c_api.dll")
#   global antlib = Libdl.dlopen("C:/Users/lukez/OneDrive/Desktop/Network Generator/Network-Generator/libantimony.dll")
# end

function loada(antString::String)
  rr = createRRInstance()
  try
    loadAntimonyString(antString)
    numModules = getNumModules()
    moduleName = getNthModuleName(numModules - 1)
    sbmlModel = getSBMLString(moduleName)
    loadSBML(rr, sbmlModel)
  finally
    freeAll()
    clearPreviousLoads()
  end
    return rr
end

function enableLoggingToConsole()
  return ccall(dlsym(rrlib, :enableLoggingToConsole), cdecl, Int8, ())
end

function setLogLevel(lvl::String)
  return ccall(dlsym(rrlib, :setLogLevel), cdecl, Int8, (Ptr{UInt8},), lvl)
end

function disableLoggingToConsole()
    ccall(dlsym(rrlib, :disableLoggingToConsole), cdecl, Bool, ())
end

function createRRInstance()
  val = ccall(dlsym(rrlib, :createRRInstance), cdecl, Ptr{Nothing}, ())
  if val == C_NULL
    error("Failed to start up roadRunner")
  end
  return val
end

function createRRInstanceEx(tempFolder::String, compiler_cstr::String)
  val = ccall(dlsym(rrlib, :createRRInstanceEx), cdecl, Ptr{Nothing}, (Ptr{UInt8}, Ptr{UInt8}), tempFolder, compiler_cstr)
  return val
end

function freeRRInstance(rr::Ptr{Nothing})
  free_status = ccall(dlsym(rrlib, :freeRRInstance), cdecl, Bool, (Ptr{Nothing},), rr)
  if free_status == false
    error(getLastError())
  end
end

function getInstallFolder()
  str = ccall(dlsym(rrlib, :getInstallFolder), cdecl, Ptr{UInt8}, ())
end

function setInstallFolder(folder::String)
  status = ccall(dlsym(rrlib, :setInstallFolder), cdecl, Bool, (Ptr{UInt8},), folder)
  if status == false
    error(getLastError())
  end
end

function getAPIVersion()
  return unsafe_string(ccall(dlsym(rrlib, :getAPIVersion), cdecl, Ptr{UInt8}, ()))
end

function getCPPAPIVersion(rr)
  return unsafe_string(ccall(dlsym(rrlib, :getCPPAPIVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getVersion()
  return ccall(dlsym(rrlib, :getVersion), cdecl, Int64, ())
end

function getVersionStr()
  return unsafe_string(ccall(dlsym(rrlib, :getVersionStr), cdecl, Ptr{UInt8}, ()))
end

function getVersionEx()
  return unsafe_string(ccall(dlsym(rrlib, :getVersionEx), cdecl, Ptr{UInt8}, ()))
end

function getExtendedAPIInfo()
  return unsafe_string(ccall(dlsym(rrlib, :getExtendedAPIInfo), cdecl, Ptr{UInt8}, ()))
end

function getBuildDate()
  return unsafe_string(ccall(dlsym(rrlib, :getBUildDate), cdecl, Ptr{UInt8}, ()))
end

function getBuildTime()
  return unsafe_string(ccall(dlsym(rrlib, :getBuildTime), cdecl, Ptr{UInt8}, ()))
end

function getBuildDateTime()
  return unsafe_string(ccall(dlsym(rrlib, :getBuildDateTime), cdecl, Ptr{UInt8}, ()))
end

function getCopyright()
  return unsafe_string(ccall(dlsym(rrlib, :getCopyright), cdecl, Ptr{UInt8}, ()))
end

function getInfo(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getInfo), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getlibSBMLVersion(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getlibSBMLVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getCurrentSBML(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function setTempFolder(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setTempFolder), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

function getTempFolder(rr::Ptr{Nothing})
  return unsafe_string(ccal(dlsym(rrlib, :getTempFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getWorkingDirectory()
  return unsafe_string(ccall(dlsym(rrlib, :getWorkingDirectory), cdecl, Ptr{UInt8}, ()))
end

function getRRCAPILocation()
  return unsafe_string(ccall(dlsym(rrlib, :getRRCAPILocation), cdecl, Ptr{UInt8}, ()))
end

function setCompiler(rr::Ptr{Nothing}, fName::String)
  status = ccall(dlsym(rrlib, :setCompiler), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fName)
  if status == false
    error(getLastError())
  end
end

function getCompiler(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCompiler), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function setCompilerLocation(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setCompilerLocation), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

function getCompilerLocation(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCompilerLocation), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function setSupportCodeFolder(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setSupportCodeFolder), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

function getSupportCodeFolder(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getSupportCodeFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function setCodeGenerationMode(rr::Ptr{Nothing}, mode::Int64)
  status = ccall(dlsym(rrlib, :setCodeGenerationMode), cdecl, Bool, (Ptr{Nothing}, Int64), rr, mode)
  if status == false
    error(getLastError())
  end
end

function hasError()
  return ccall(dlsym(rrlib, :hasError), cdecl, Bool, ())
end

function getLastError()
  return unsafe_string(ccall(dlsym(rrlib, :getLastError), cdecl, Ptr{UInt8}, ()))
end

function setComputeAndAssignConservationLaws(rr::Ptr{Nothing}, OnOrOff::Bool)
  status = ccall(dlsym(rrlib, :setComputeAndAssignConservationLaws), cdecl, Bool, (Ptr{Nothing} , Bool), rr, OnOrOff)
  if status == false
    error(getLastError())
  end
end

function loadSBML(rr::Ptr{Nothing}, sbml::String)
  status = ccall(dlsym(rrlib, :loadSBML), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, sbml)
  if status == false
    error(getLastError())
  end
end

function loadSBMLEx(rr::Ptr{Nothing}, sbml::String, forceRecompile::Bool)
  status = ccall(dlsym(rrlib, :loadSBMLEx), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, sbml, forceRecompile)
  if status == false
    error(getLastError())
  end
end

function loadSBMLFromFile(rr::Ptr{Nothing}, fileName::String)
  status = ccall(dlsym(rrlib, :loadSBMLFromFile), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileName)
  if status == false
    error(getLastError())
  end
end

function loadSBMLFromFileE(rr::Nothing, fileName::String, forceRecompile::Bool)
  status = ccall(dlsym(rrlib, :loadSBMLFromFileE), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, fileName, forceRecompile)
  if status == false
    error(getLastError())
  end
end

function clearModel(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :clearModel), cdecl, Int8, (Ptr{Nothing}, ), rr)
  if status == false
    error(getLastError())
  end
end

function isModelLoaded(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :isModelLoaded), cdecl, Bool, (Ptr{Nothing},), rr)
end

function loadSimulationSettings(rr::Ptr{Nothing}, fileName::String)
  status = call(dlsym(rrlib, :loadSimulationSettings), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileName)
  if status == false
    error(getLastError())
  end
end

function getSBML(rr::Ptr{Nothing})
   return unsafe_string(ccall(dlsym(rrlib, :getSBML), Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getParamPromotedSBML(rr::Ptr{Nothing}, sArg::String)
  return unsafe_string(ccall(dlsym(rrlib, :getParamPromotedSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, sArg))
end

function setConfigurationXML(rr::Ptr{Nothing}, caps::String)
  ccall(dlsym(rrlib, :setConfigurationXML), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, caps)
end

function getConfigurationXML(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getConfigurationXML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function unLoadModel(rr)
  return ccall(dlsym(rrlib, :unLoadModel), cdecl, Bool, (Ptr{Nothing},), rr)
end

function setTimeStart(rr, timeStart::Float64)
  return ccall(dlsym(rrlib, :setTimeStart), cdecl, Bool, (Ptr{Nothing}, Float64), rr, timeStart)
end

function setTimeEnd(rr, timeEnd::Float64)
  return ccall(dlsym(rrlib, :setTimeEnd), cdecl, Bool, (Ptr{Nothing}, Float64), rr, timeEnd)
end

function setNumPoints(rr, nrPoints::Int64)
  return ccall(dlsym(rrlib, :setNumPoints), cdecl, Bool, (Ptr{Nothing}, Int64), rr, nrPoints)
end

function getTimeStart(rr)
  #timeStart = Array(Float64, 1)
  timeStart = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getTimeStart), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, timeStart)
  return value[1]
end

function getTimeEnd(rr)
  #timeEnd = Array(Float64, 1)
  timeEnd = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getTimeEnd), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, timeEnd)
  return value[1]
end

function getNumPoints(rr)
  #numPoints = Array(Int64, 1)
  numPoints = Array{Int64}(undef,1)
  ccall(dlsym(rrlib, :getNumPoints), cdecl, Bool, (Ptr{Nothing}, Ptr{Int64}), rr, numPoints)
end

function setTimeCourseSelectionList(rr, list::String)
  return ccall(dlsym(rrlib, :setTimeCourseSelectionList), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, list)
end

function getTimeCourseSelectionList(rr)
  return ccall(dlsym(rrlib, :getTimeCourseSelectionList), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function simulateEx(rr, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64)
  return ccall(dlsym(rrlib, :simulateEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Float64, Float64, Int64), rr, timeStart, timeEnd, numberOfPoints)
end

function getSimulationResult(rr)
  return ccall(dlsym(rrlib, :getSimulationResult), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getReactionIds(rr)
  return ccall(dlsym(rrlib, :getReactionIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getRatesOfChange(rr)
  return ccall(dlsym(rrlib, :getRatesOfChange), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getRatesOfChangeIds(rr)
  return ccall(dlsym(rrlib, :getRatesOfChangeIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getUnscaledElasticityMatrix(rr)
  return ccall(dlsym(rrlib, :getUnscaledElasticityMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getScaledElasticityMatrix(rr)
  return ccall(dlsym(rrlib, :getScaledElasticityMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getValue(rr, symbolId::String)
  #value = Array{Float64}(undef,1)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getValue), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Float64}), rr, symbolId, value)
end

function setValue(rr, symbolId::String, value::Float64)
  return ccall(dlsym(rrlib, :setValue), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Float64), rr, symbolId, value)
end

function getStoichiometryMatrix(rr)
  return ccall(dlsym(rrlib, :getStoichiometryMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getConservationMatrix(rr)
  return ccall(dlsym(rrlib, :getConservationMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getLinkMatrix(rr)
  return ccall(dlsym(rrlib, :getLinkMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getNrMatrix(rr)
  return ccall(dlsym(rrlib, :getNrMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getNumberOfReactions(rr)
  return ccall(dlsym(rrlib, :getNumberOfReactions), cdecl, Int64, (Ptr{Nothing},), rr)
end

function getReactionRate(rr, rateNr::Int64)
  #value = Array{Float64}(undef,1)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getReactionRate), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, rateNr, value)
  return value[1]
end

function getReactionRates(rr)
  return ccall(dlsym(rrlib, :getReactionRates), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getNumberOfBoundarySpecies(rr)
  return ccall(dlsym(rrlib, :getNumberOfBoundarySpecies), cdecl, Cint, (Ptr{Nothing},), rr)
end

function getBoundarySpeciesIds(rr)
  data = ccall(dlsym(rrlib, :getBoundarySpeciesIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num_b_species = getNumberOfBoundarySpecies(rr)
  println("this is the number of boundary species", num_b_species)
  b_species = Array{String}(undef, num_b_species)
  try
    for i = 1:num_b_species
      b_species[i] = getStringElement(data, i - 1)
    end
  finally
    freeStringArray(data)
  end
  return b_species
end

function getNumberOfFloatingSpecies(rr)
  return ccall(dlsym(rrlib, :getNumberOfFloatingSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

function getFloatingSpeciesIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getFloatingSpeciesIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num_species = getNumberOfFloatingSpecies(rr)
  species = Array{String}(undef, num_species)
  try
    for i = 1:num_species
      species[i] = getStringElement(data, i - 1)
    end
  finally
    freeStringArray(data)
  end
  return species
end

function getNumberOfGlobalParameters(rr)
  return ccall(dlsym(rrlib, :getNumberOfGlobalParameters), cdecl, Int64, (Ptr{Nothing},), rr)
end

function getGlobalParameterIds(rr)
  data = ccall(dlsym(rrlib, :getGlobalParameterIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num_elem = getNumberOfGlobalParameters(rr)
  println("number of elements: ", num_elem)
  data_arr = Array{String}(undef, num_elem)
  try
    for i = 1:num_elem
      data_arr[i] = getStringElement(data, i - 1)
    end
  finally
    freeStringArray(data)
  end
  return data_arr
end

function getFloatingSpeciesInitialConcentrationByIndex(rr, index::Int64)
  #value = Array{Float64}(undef,1)
  value = Array{Floating64}(undef,1)
  ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  return value[1]
end

function getFloatingSpeciesConcentrations(rr)
  return ccall(dlsym(rrlib, :getFloatingSpeciesConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

function getBoundarySpeciesConcentrations(rr)
  return ccall(dlsym(rrlib, :getBoundarySpeciesConcentrations), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getFloatingSpeciesInitialConcentrations(rr)
  return ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrations), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function setFloatingSpeciesByIndex(rr, index::Int64, value::Float64)
  return ccall(dlsym(rrlib, :setFloatingSpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
end

function setBoundarySpeciesByIndex(rr, index::Int64, value::Float64)
  return ccall(dlsym(rrlib, :setBoundarySpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
end

function setGlobalParameterByIndex(rr, index::Int64, value::Float64)
  return ccall(dlsym(rrlib, :setGlobalParameterByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
end

function setFloatingSpeciesInitialConcentrationByIndex(rr, index::Int64, value::Float64)
  return ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
end

function setFloatingSpeciesInitialConcentrations(rr, vec)
  return ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{Nothing}), rr, vec)
end

function setFloatingSpeciesConcentrations(rr, vec)
  return ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{Nothing}), rr, vec)
end

function setBoundarySpeciesConcentrations(rr, vec)
  return ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{Nothing}), rr, vec)
end

function oneStep(rr, currentTime::Float64, stepSize::Float64)
  #value = Array{Float64}(undef,1)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :oneStep), cdecl, Bool, (Ptr{Nothing}, Float64, Float64), rr, currentTime, stepSize)
end

function getGlobalParameterValues(rr)
  return ccall(dlsym(rrlib, :getGlobalParameterValues), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getAvailableTimeCourseSymbols(rr)
  return ccall(dlsym(rrlib, :getAvailableTimeCourseSymbols), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getAvailableSteadyStateSymbols(rr)
  return ccall(dlsym(rrlib, :getAvailableSteadyStateSymbols), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getBoundarySpeciesByIndex(rr, index::Int64)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getBoundarySpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  return value[1]
end

function getFloatingSpeciesByIndex(rr, index::Int64)
  #value = Array{Float64}(undef,1)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getFloatingSpeciesByIndex ), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  return value[1]
end

function getGlobalParameterByIndex(rr, index::Int64)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getGlobalParameterByIndex ), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  return value[1]
end

function getNumberOfDependentSpecies(rr)
  return ccall(dlsym(rrlib, :getNumberOfDependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

function getNumberOfIndependentSpecies(rr)
  return ccall(dlsym(rrlib, :getNumberOfIndependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

function steadyState(rr)
  value = Array{Float64}(undef, 1)
  status = ccall(dlsym(rrlib, :steadyState), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function evalModel(rr)
  return ccall(dlsym(rrlib, :evalModel), cdecl, Bool, (Ptr{Nothing},), rr)
end

function computeSteadyStateValues(rr)
  return ccall(dlsym(rrlib, :computeSteadyStateValues), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function setSteadyStateSelectionList(rr, list::String)
  return ccall(dlsym(rrlib, :setSteadyStateSelectionList), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, list)
end

function getSteadyStateSelectionList(rr)
  return ccall(dlsym(rrlib, :getSteadyStateSelectionList), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getFullJacobian(rr)
  return ccall(dlsym(rrlib, :getFullJacobian), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getReducedJacobian(rr)
  return ccall(dlsym(rrlib, :getReducedJacobian), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getEigenvalues(rr)
  return ccall(dlsym(rrlib, :getEigenvalues), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getFloatingSpeciesInitialConditionIds(rr)
  return ccall(dlsym(rrlib, :getFloatingSpeciesInitialConditionIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getRatesOfChangeEx(rr, vec)
  return ccall(dlsym(rrlib, :getRatesOfChangeEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Ptr{Nothing}), rr, vec)
end

function getReactionRatesEx(rr, vec)
  return ccall(dlsym(rrlib, :getReactionRatesEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Ptr{Nothing}), rr, vec)
end

function getElasticityCoefficientIds(rr)
  return ccall(dlsym(rrlib, :getElasticityCoefficientIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getEigenvalueIds(rr)
  return ccall(dlsym(rrlib, :getEigenvalueIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getFluxControlCoefficientIds(rr)
  return ccall(dlsym(rrlib, :getFluxControlCoefficientIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getUnscaledConcentrationControlCoefficientIds(rr)
  return ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getNumberOfCompartments(rr)
  return ccall(dlsym(rrlib, :getNumberOfCompartments), cdecl, Int64, (Ptr{Nothing},), rr)
end

function getCompartmentByIndex(rr, index::Int64)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib :getCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, inde, value)
  return value[1]
end

function setCompartmentByIndex(rr, index::Int64, value::Float64)
  return ccall(dlsym(rrlib, :setCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
end

function getCompartmentIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getCompartmentIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end

function getRateOfChange(rr, index::Int64)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib :getRateOfChange), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, inde, value)
  return value[1]
end

function getScaledFloatingSpeciesElasticity(rr::Ptr{Nothing}, reactionId::String, speciesId::String)
  value = Array{Float64}(undef,1)
  ccall(dlsym(rrlib, :getScaledFloatingSpeciesElasticity), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, reactionId, speciesId, value)
end



function getUnscaledFluxControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getConcentrationControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getConcentrationControlCoefficientIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getUnscaledConcentrationControlCoefficientMatrix(rr)
  return ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

function getScaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getScaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

function getUnscaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getScaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getScaledFluxControlCoefficientMatrix), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function getuCC(rr::Ptr{Nothing}, variable::String, parameter::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getuCC), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, variable, parameter, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getCC(rr::Ptr{Nothing}, variable::String, parameter::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getCC), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, variable, parameter, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getEE(rr::Ptr{Nothing}, name::String, species::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getEE), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, name, species, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getuEE(rr::Ptr{Nothing}, name::String, species::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getuEE), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, name, species, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getSeed(rr::Ptr{Nothing})
  value = Array{Float32}(undef,1)
  status = ccall(dlsym(rrlib, :getSeed), cdecl, Bool, (Ptr{Nothing}, Ptr{Float32}), rr, value)
  if status == false
    error(getLastError())
  end
  return result
end

function setSeed(rr::Ptr{Nothing}, result::Float32)
  status = ccall(dlsym(rrlib, :setSeed), cdecl, Bool, (Ptr{Nothing}, Float32), rr, result)
  if status == false
    error(getLastError())
  end
end

function gillespie(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :gillespie), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function gillespieEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64)
  return ccall(dlsym(rrlib, :gillespieEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Float64, Float64), rr, timeStart, timeEnd)
end

function gillespieOnGrid(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :gillespieOnGrid), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
end

function gillespieOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64)
  return ccall(dlsym(rrlib, :gillespieOnGridEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Float64, Float64, Int64), rr, timeStart, timeEnd, numberOfPoints)
end

function gillespieMeanOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanOnGrid), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
end

function gillespieMeanOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanOnGridEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
end

function gillespieMeanSDOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanSDOnGrid), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
end

function gillespieMeanSDOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanSDOnGridEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
end

function resetRR(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :reset), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

function resetAllRR(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :resetAll), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

function resetToOriginRR(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :resetToOrigin), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

function setConfigBool(key::String, value::Bool)
    status = ccall(dlsym(rrlib, :setConfigBool), cdecl, Bool, (Ptr{UInt8}, Cint), key, value)
    println(status)
    if status == false
      error(getLastError())
    # elseif status != true
    #   println("this is the status: ", status)
    #   println("boolean comparison: ", status != true)
    #   error("neither true nor false")
    end
    return status
end

function getConfigBool(key::String)
  return ccall(dlsym(rrlib, :getConfigBool), cdecl, Bool, (Ptr{UInt8},), key)
end

function setConfigInt(key::String, value::Int64)
    status = ccall(dlsym(rrlib, :setConfigInt), cdecl, Bool, (Ptr{UInt8}, Cint), key, value)
    println(status)
    if status == false
      error(getLastError())
    end
end

function getConfigInt(key::String)
  return ccall(dlsym(rrlib, :getConfigInt), cdecl, Int64, (Ptr{UInt8},), key)
end

function setConfigDouble(key::String, value::Float64)
  status = ccall(dlsym(rrlib, :setConfigDouble), cdecl, Bool, (Ptr{UInt8}, Cdouble), key, value)
  if status == false
    error(getLastError())
  end
end

function getConfigDouble(key::String)
  return ccall(dlsym(rrlib, :getConfigDouble), cdecl, Float64, (Ptr{UInt8},), key)
end

function getListOfConfigKeys()
  config_keys = String[]
  str_arr = ccall(dlsym(rrlib, :getListOfConfigKeys), cdecl, Ptr{RRStringArray}, ())
  num_element = getNumberOfStringElements(str_arr)
  for i = 1:num_element
    key = getStringElement(str_arr, i - 1)
    push!(config_keys, key)
  end
  freeStringArray(str_arr)
  return config_keys
end

### End






function resultsToJulia(resultHandle)
  rows = getRRDataNumRows(resultHandle)
  cols = getRRDataNumCols(resultHandle)
  results = Array{Float64}(undef, rows, cols)
  for i = 0:rows
    for j = 0:cols
      results[i + 1, j + 1] = getRRCDataElement(resultHandle, i, j)
    end
  end
  return results
end

function resultsColumn(resultHandle, column::Int64)
  rows = getRRDataNumRows(resultHandle)
  #results = Array(Float64, rows)
  results = Array{Float64}(undef,rows)
  for i = 0:rows - 1
    results[i + 1] = getRRCDataElement(resultHandle, i, column)
  end
  return results
end

function getNumberOfFloatingSpecies(rr)
     n = ccall(dlsym(rrlib, :getNumberOfFloatingSpecies), stdcall, Int64, (UInt,), rr)
     return n
end

function simulate(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :simulate), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
  print(data)
  return simulate_helper(data)
end

function simulate(rr::Ptr{Nothing}, startTime::Number, endTime::Number, steps::Int)
  data = ccall(dlsym(rrlib, :simulateEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Cdouble, Cdouble, Cint), rr, startTime, endTime, steps)
  return simulate_helper(data)
end

function simulate_helper(data::Ptr{RRCData})
  num_row = getRRDataNumRows(data)
  num_col = getRRDataNumCols(data)
  println(num_row)
  println(num_col)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getRRCDataElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeRRCData(data)
  end
  return data_arr
end

function createRRCData(rrDataHandle)
    return ccall(dlsym(rrlib, :createRRCData), cdecl, UInt, (Ptr{Nothing},), rrDataHandle)
end

function getGlobalParameterIdsNew(rr)
  return unsafe_load(ccall(dlsym(rrlib, :getGlobalParameterIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr))
end

function getGlobalParameterIdsNoLoad(rr)
  return ccall(dlsym(rrlib, :getGlobalParameterIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end

function addSpecies(rr::Ptr{Nothing}, sid::String, compartment::String, initialAmount::Float64, substanceUnit::String, regen::Bool)
  status = false
  if regen == true
    status = ccall(Libdl.dlsym(rrlib, :addSpecies), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Cdouble, Ptr{UInt8}), rr, sid, compartment, initialAmount, substanceUnit)
  else
    status = ccall(Libdl.dlsym(rrlib, :addSpeciesNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Cdouble, Ptr{UInt8}), rr, sid, compartment, initialAmount, substanceUnit)
  end
  if status == false
    error(getLastError())
  end
end

function removeSpecies(rr::Ptr{Nothing}, sid::String, regen::Bool)
  status = false
  if regen == true
    status = ccall(Libdl.dlsym(rrlib, :removeSpecies), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, sid)
  else
    status = ccall(Libdl.dlsym(rrlib, :removeSpeciesNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, sid)
  end
  if status == false
    error(getLastError())
  end
end

function addCompartment(rr, cid::String, initVolume::Float64, regen::Bool)
  status = false
  if regen == true
    status = ccall(dlsym(rrlib, :addCompartment), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, cid, initVolume)
  else
    status = ccall(dlsym(rrlib, :addCompartmentNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, cid, initVolume)
  end
  if status == false
    error(getLastError())
  end
end

function addReaction(rr::Ptr{Nothing}, rid::String, reactants::Array{String}, products::Array{String}, kineticLaw::String, regen::Bool)
  numReactants = length(reactants)
  numProducts = length(products)
  status = 0
  if regen == true
    status = ccall(dlsym(rrlib, :addReaction), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Ptr{UInt8}}, Cint, Ptr{Ptr{UInt8}}, Cint, Ptr{UInt8}), rr, rid, reactants, numReactants, products, numProducts, kineticLaw)
  else
    status = ccall(dlsym(rrlib, :addReactionNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Ptr{UInt8}}, Cint, Ptr{Ptr{UInt8}}, Cint, Ptr{UInt8}), rr, rid, reactants, numReactants, products, numProducts, kineticLaw)
  end
  if status == false
    error(getLastError())
  end
end

function addParameter(rr::Ptr{Nothing}, pid::String, value::Float64, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addParameter), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, pid, value)
  else
    status = ccall(dlsym(rrlib, :addParameterNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, pid, value)
  end
  if status == false
    error(getLastError())
  end
end

function isModelLoaded(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :isModelLoaded), cdecl, Int8, (Ptr{Nothing}, ), rr)
end
end # module
