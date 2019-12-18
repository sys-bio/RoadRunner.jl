module RoadRunnerJulia
__precompile__(false)

export loada
export createRRInstance
export simulate
export getFloatingSpeciesIds
export steadyState


using Libdl
push!(Libdl.DL_LOAD_PATH, "./")
current_dir = @__DIR__
rr_api = joinpath(current_dir, "roadrunner_c_api.dll")
antimony_api = joinpath(current_dir, "libantimony.dll")

rrlib = Libdl.dlopen(rr_api)
antlib = Libdl.dlopen(antimony_api)
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

###############################################################################
#            Library Initialization and Termination Methods                   #
###############################################################################
"""
    createRRInstance()
Initialize  and return a new roadRunner instances.
"""
function createRRInstance()
  val = ccall(dlsym(rrlib, :createRRInstance), cdecl, Ptr{Nothing}, ())
  if val == C_NULL
    error("Failed to start up roadRunner")
  end
  return val
end

"""
    createRRInstanceEx(tempFolder::String, compiler_cstr::String)
Initialize  and return a new roadRunner instance.
"""
function createRRInstanceEx(tempFolder::String, compiler_cstr::String)
  val = ccall(dlsym(rrlib, :createRRInstanceEx), cdecl, Ptr{Nothing}, (Ptr{UInt8}, Ptr{UInt8}), tempFolder, compiler_cstr)
  return val
end

"""
    freeRRInstance(rr::Ptr{Nothing})
Free the roadRunner instance.
"""
function freeRRInstance(rr::Ptr{Nothing})
  free_status = ccall(dlsym(rrlib, :freeRRInstance), cdecl, Bool, (Ptr{Nothing},), rr)
  if free_status == false
    error(getLastError())
  end
end

"""
    getInstallFolder()
Returns the folder in which the RoadRunner API is installed.
"""
function getInstallFolder()
  str = ccall(dlsym(rrlib, :getInstallFolder), cdecl, Ptr{UInt8}, ())
end
"""
    getInstallFolder(folder::String)
Set the internal string containing the folder in where the RoadRunner C API is installed.
"""
function setInstallFolder(folder::String)
  status = ccall(dlsym(rrlib, :setInstallFolder), cdecl, Bool, (Ptr{UInt8},), folder)
  if status == false
    error(getLastError())
  end
end

"""
    setComputeAndAssignConservationLaws(rr::Ptr{Nothing}, OnOrOff::Bool)
Enable or disable conservation analysis.
"""
function setComputeAndAssignConservationLaws(rr::Ptr{Nothing}, OnOrOff::Bool)
  status = ccall(dlsym(rrlib, :setComputeAndAssignConservationLaws), cdecl, Bool, (Ptr{Nothing} , Bool), rr, OnOrOff)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                            Read and Write Models                            #
###############################################################################
# RRHandle's type is Ptr{Void}, in JUlia, Void is called Nothing

"""
    loadSBML(rr::Ptr{Nothing}, sbml::String)
Load a model from an SBML string.
"""
function loadSBML(rr::Ptr{Nothing}, sbml::String)
  status = ccall(dlsym(rrlib, :loadSBML), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, sbml)
  if status == false
    error(getLastError())
  end
end

"""
    loadSBMLEx(rr::Ptr{Nothing}, sbml::String, forceRecompile::Bool)
Load a model from an SBML string.
"""
function loadSBMLEx(rr::Ptr{Nothing}, sbml::String, forceRecompile::Bool)
  status = ccall(dlsym(rrlib, :loadSBMLEx), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, sbml, forceRecompile)
  if status == false
    error(getLastError())
  end
end
"""
    loadSBMLFromFile(rr::Ptr{Nothing}, fileName::String)
Load a model from a SBML file.
"""
function loadSBMLFromFile(rr::Ptr{Nothing}, fileName::String)
  status = ccall(dlsym(rrlib, :loadSBMLFromFile), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileName)
  if status == false
    error(getLastError())
  end
end

"""
    loadSBMLFromFile(rr::Nothing, fileName::String, forceRecompile::Bool)
Load a model from a SBML file, force recompilation.
"""
function loadSBMLFromFileE(rr::Nothing, fileName::String, forceRecompile::Bool)
  status = ccall(dlsym(rrlib, :loadSBMLFromFileE), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, fileName, forceRecompile)
  if status == false
    error(getLastError())
  end
end

"""
    clearModel(rr::Ptr{Nothing)
Unload current model.
"""
function clearModel(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :clearModel), cdecl, Int8, (Ptr{Nothing}, ), rr)
  if status == false
    error(getLastError())
  end
end

"""
    isModelLoaded(rr::Ptr{Nothing})
check if a model is loaded.
"""
function isModelLoaded(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :isModelLoaded), cdecl, Bool, (Ptr{Nothing},), rr)
end
"""
    loadSimulationSettings(rr::Ptr{Nothing}, fileName::String)
Load simulation settings from a file.
"""
function loadSimulationSettings(rr::Ptr{Nothing}, fileName::String)
  status = call(dlsym(rrlib, :loadSimulationSettings), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileName)
  if status == false
    error(getLastError())
  end
end
"""
    getCurrentSBM(handle::Ptr{Nothing})
Retrieve the current state of the model in the form of an SBML string.
"""
function getCurrentSBML(handle::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), handle))
end

"""
    getSBM(rr::Ptr{Nothing})
Retrieve the SBML model that was last loaded into roadRunner.
"""
function getSBML(rr::Ptr{Nothing})
   return unsafe_string(ccall(dlsym(rrlib, :getSBML), Ptr{UInt8}, (Ptr{Nothing},), rr))
end

###############################################################################
#                          Utilities Functions                               #
###############################################################################

## Attention: returns null
"""
    getAPIVersion()
Retrieve the current version number of the C API library.
"""
function getAPIVersion()
  return unsafe_string(ccall(dlsym(rrlib, :getAPIVersion), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getCPPAPIVersion(rr::Ptr{Nothing})
Retrieve the current version number of the C++ API (Core RoadRunner API) library..
"""
function getCPPAPIVersion(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCPPAPIVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

"""
    getVersion()
Get the version number.
Returns: the roadrunner version number in the form or 102030 if the number is 1.2.3
returns the individual version numbers as XXYYZZ where XX is the major version, YY the minor and ZZ the revision, eg 10000, or 10100, 20000 etc
"""
function getVersion()
  return ccall(dlsym(rrlib, :getVersion), cdecl, Int64, ())
end

"""
    getVersionStr()
returns roadrunner as a string, i.e. "1.0.0"
"""
function getVersionStr()
  return unsafe_string(ccall(dlsym(rrlib, :getVersionStr), cdecl, Ptr{UInt8}, ()))
end

"""
    getVersionEx()
returns something like "1.0.0; compiled with clang "3.3 (tags/RELEASE_33/final)" on date Dec 8 2013, 17:24:57'
"""
function getVersionEx()
  return unsafe_string(ccall(dlsym(rrlib, :getVersionEx), cdecl, Ptr{UInt8}, ()))
end


## Attention: returns null
"""
    getExtendedAPIInfo()
Retrieve extended API info. Returns null if it fails, otherwise it returns a string with the info.
"""
## Attention: returns null
function getExtendedAPIInfo()
  return unsafe_string(ccall(dlsym(rrlib, :getExtendedAPIInfo), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getBuildDate()
Retrieve the current build date of the library.
"""
function getBuildDate()
  return unsafe_string(ccall(dlsym(rrlib, :getBUildDate), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getBuildTime()
Retrieve the current build time (HH:MM:SS) of the library.
"""
function getBuildTime()
  return unsafe_string(ccall(dlsym(rrlib, :getBuildTime), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getBuildDateTime()
Retrieve the current build date + time of the library.
"""
function getBuildDateTime()
  return unsafe_string(ccall(dlsym(rrlib, :getBuildDateTime), cdecl, Ptr{UInt8}, ()))
end
## Attention: returns null
"""
    getCopyright(rr::Ptr{Nothing})
Retrieve the current copyright notice for the library.
"""
function getCopyright(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCopyright), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getInfo(rr::Ptr{Nothing})
Retrieve the current version number of the libSBML library.
"""
function getInfo(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getInfo), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end
## Attention: returns null
"""
    getlibSBMLVersion(rr::Ptr{Nothing})
Retrieve info about current state of roadrunner, e.g. loaded model, conservationAnalysis etc.
"""
function getlibSBMLVersion(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getlibSBMLVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end


"""
    setTempFolder(rr::Ptr{Nothing}, folder::String)
Set the path to the temporary folder where the C code will be stored.
When RoadRunner is run in C generation mode it uses a temporary folder to store the generated C source code. This method can be used to set the temporary folder path if necessary.
"""
function setTempFolder(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setTempFolder), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

## Attention: returns null
"""
    getTempFolder(rr::Ptr{Nothing})
Retrieve the current temporary folder path. When RoadRunner is run in C generation mode it uses a temporary folder to store the generate C source code. This method can be used to get the current value for the temporary folder path.
"""
function getTempFolder(rr::Ptr{Nothing})
  return unsafe_string(ccal(dlsym(rrlib, :getTempFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

## Attention: returns null
"""
    getWorkingDirectory()
Retrieve the current working directory path.
"""
function getWorkingDirectory()
  return unsafe_string(ccall(dlsym(rrlib, :getWorkingDirectory), cdecl, Ptr{UInt8}, ()))
end

## Attention: returns null
"""
    getRRCAPILocation()
Retrieve the directory path of the shared rrCApi library.
"""
function getRRCAPILocation()
  return unsafe_string(ccall(dlsym(rrlib, :getRRCAPILocation), cdecl, Ptr{UInt8}, ()))
end

"""
    setCompiler(rr::Ptr{Nothing}, fName::String)
Set the path and filename to the compiler to be used by roadrunner.
"""
function setCompiler(rr::Ptr{Nothing}, fName::String)
  status = ccall(dlsym(rrlib, :setCompiler), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fName)
  if status == false
    error(getLastError())
  end
end

"""
    getCompiler(rr::Ptr{Nothing}))
Get the name of the compiler currently being used by roadrunner.
"""
function getCompiler(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCompiler), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

"""
    setCompilerLocation(rr::Ptr{Nothing}, folder::String)
Set the path to a folder containing the compiler being used. Returns true if successful
"""
function setCompilerLocation(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setCompilerLocation), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

## Attention: returns null
"""
    getCompilerLocation(rr::Ptr{Nothing})
Get the path to a folder containing the compiler being used. Returns the path if successful, NULL otherwise
"""
function getCompilerLocation(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCompilerLocation), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

"""
    setSupportCodeFolder(rr::Ptr{Nothing}, folder::String)
Set the path to a folder containing support code for model generation.
"""
function setSupportCodeFolder(rr::Ptr{Nothing}, folder::String)
  status = ccall(dlsym(rrlib, :setSupportCodeFolder), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, folder)
  if status == false
    error(getLastError())
  end
end

## Attention: returns null
"""
    getSupportCodeFolder(rr::Ptr{Nothing})
Get the path to a folder containing support code.
"""
function getSupportCodeFolder(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getSupportCodeFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

"""
    setCodeGenerationMode(rr::Ptr{Nothing}, mode::Int64)
Set the runtime generation option [Not yet implemented]. RoadRunner can either execute a model by generating, compiling and linking self-generated C code or it can employ an internal interpreter to evaluate the model equations. The later method is useful when the OS forbids the compiling of externally generated code.
"""
function setCodeGenerationMode(rr::Ptr{Nothing}, mode::Int64)
  status = ccall(dlsym(rrlib, :setCodeGenerationMode), cdecl, Bool, (Ptr{Nothing}, Int64), rr, mode)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                      Error Handling Functions                               #
###############################################################################
## Atttention Returns false
"""
    hasError()
Check if there is an error string to retrieve. Example: status = hasError (void)
"""
function hasError()
  return ccall(dlsym(rrlib, :hasError), cdecl, Bool, ())
end

## Attention Returns False
"""
    getLastError()
Retrieve the current error string. Example, str = getLastError (void);
"""
function getLastError()
  return unsafe_string(ccall(dlsym(rrlib, :getLastError), cdecl, Ptr{UInt8}, ()))
end

###############################################################################
#                         Logging Functionality                               #
###############################################################################

"""
    enableLoggingToConsole()
Enable logging to console.
"""
function enableLoggingToConsole()
  status = ccall(dlsym(rrlib, :enableLoggingToConsole), cdecl, Int8, ())
  if status == false
    error(getLastError())
  end
end

"""
    disableLoggingToConsole()
Disable logging to console.
"""
function disableLoggingToConsole()
  status = ccall(dlsym(rrlib, :disableLoggingToConsole), cdecl, Bool, ())
  if status == false
    error(getLastError())
  end
end

"""
    enableLoggingToFile()
Enable logging to logFile.
"""
function enableLoggingToFile()
  status = ccall(dlsym(rrlib, :enableLoggingToFile), cdecl, Bool, ())
  if status == false
    error(getLastError())
  end
end
"""
    enableLoggingToFileWithPath(path::String)
Enable logging to a log file with the specified path.
"""
function enableLoggingToFileWithPath(path::String)
  status = ccall(dlsym(rrlib, :enableLoggingToConsole), cdecl, Bool, (Ptr{UInt8},), path)
  if status == false
    error(getLastError())
  end
end

"""
    disableLoggingToFile()
Disable logging to logFile.
"""
function disableLoggingToFile()
  status = ccall(dlsym(rrlib, :disableLoggingToFile), cdecl, Bool, ())
  if status == false
    error(getLastError())
  end
end
## Attention Returns False
"""
    setLogLevel(lvl::String)
Set the logging status level The logging level is determined by the following strings.
"ANY", "DEBUG5", "DEBUG4", "DEBUG3", "DEBUG2", "DEBUG1", "DEBUG", "INFO", "WARNING", "ERROR"
Example: setLogLevel ("DEBUG4")
"""
function setLogLevel(lvl::String)
  return ccall(dlsym(rrlib, :setLogLevel), cdecl, Int8, (Ptr{UInt8},), lvl)
end

## Attention Returns Null
"""
    getLogLevel()
Get the logging status level as a pointer to a string. The logging level can be one of the following strings
"ANY", "DEBUG5", "DEBUG4", "DEBUG3", "DEBUG2", "DEBUG1", "DEBUG", "INFO", "WARNING", "ERROR"
Example str = getLogLevel (void)
"""
function getLogLevel()
  return unsafe_string(ccall(dlsym(rrlib, :getLogLevel), cdecl, Ptr{UInt8}, ()))
end
 ## Attention Returns Null
"""
    getLogFileName()
Get a pointer to the string that holds the logging file name path. Example: str = getLogFileName (void)
"""
function getLogFileName()
  return unsafe_string(ccall(dlsym(rrlib, :getLogFileName), cdecl, Ptr{UInt8}, ()))
end

## Todo, enum type
"""
    logMsg()
Create a log message.
"""
function logMsg()
end


###############################################################################
#                         Current State of System                             #
###############################################################################

"""
    getValue(rr::Ptr{Nothing}, symbolId::String)
Get the value for a given symbol, use getAvailableTimeCourseSymbols(void) for a list of symbols.
Example status = getValue (rrHandle, "S1", &value);
"""
function getValue(rr::Ptr{Nothing}, symbolId::String)
  #value = Array{Float64}(undef,1)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getValue), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Float64}), rr, symbolId, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setValue(rr::Ptr{Nothing}, symbolId::String, value::Float64)
Set the value for a given symbol, use getAvailableTimeCourseSymbols(void) for a list of symbols.
Example: status = setValue (rrHandle, "S1", 0.5);
"""
function setValue(rr::Ptr{Nothing}, symbolId::String, value::Float64)
  status = ccall(dlsym(rrlib, :setValue), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Float64), rr, symbolId, value)
  if status == false
    error(getLastError())
  end
end
"""
    evalModel(rr::Ptr{Nothing})
Evaluate the current model, that it update all assignments and rates of change. Do not carry out an integration step.
"""
function evalModel(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :evalModel), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

## To test
"""
    getEigenvalueIds(rr::Ptr{Nothing})
Obtain the list of eigenvalue Ids.
"""
function getEigenvalueIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getEigenvalueIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  eigenValueIds = convertStringArrayToJuliaArray(data)
  return eigenValueIds
end
"""
    getAvailableTimeCourseSymbols(rr::Ptr{Nothing})
Obtain the list of all available symbols.
"""
function getAvailableTimeCourseSymbols(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getAvailableTimeCourseSymbols), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end
"""
    getAvailableSteadyStateSymbols(rr::Ptr{Nothing})
Obtain the list of all available steady state symbols.
"""
function getAvailableSteadyStateSymbols(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getAvailableSteadyStateSymbols), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end


###############################################################################
#                         Time Course Simulation                              #
###############################################################################
"""
    setConfigurationXML(rr::Ptr{Nothing}, caps::String)
Set the simulator's capabilities.
"""
function setConfigurationXML(rr::Ptr{Nothing}, caps::String)
  status = ccall(dlsym(rrlib, :setConfigurationXML), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, caps)
  if status == false
    error(getLastError())
  end

##Attention Returns Null
"""
    getConfigurationXML(rr::Ptr{Nothing})
Get the simulator's capabilities.
"""
function getConfigurationXML(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getConfigurationXML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

"""
    setTimeStart(rr::Ptr{Nothing}, timeStart::Number)
Set the time start for a time course simulation.
"""
function setTimeStart(rr::Ptr{Nothing}, timeStart::Number)
   status = ccall(dlsym(rrlib, :setTimeStart), cdecl, Bool, (Ptr{Nothing}, Float64), rr, timeStart)
   if status == false
     error(getLastError())
   end
end
"""
    setTimeEnd(rr::Ptr{Nothing}, timeEnd::Number)
Set the time end for a time course simulation.
"""
function setTimeEnd(rr::Ptr{Nothing}, timeEnd::Number)
  status = ccall(dlsym(rrlib, :setTimeEnd), cdecl, Bool, (Ptr{Nothing}, Float64), rr, timeEnd)
  if status == false
    error(getLastError())
  end
end
"""
    setNumPoints(rr::Ptr{Nothing}, nrPoints::Int64)
Set the number of points to generate in a time course simulation.
"""
function setNumPoints(rr::Ptr{Nothing}, nrPoints::Int64)
  status = ccall(dlsym(rrlib, :setNumPoints), cdecl, Bool, (Ptr{Nothing}, Int64), rr, nrPoints)
  if status == false
    error(getLastError())
  end
end

"""
    setTimeCourseSelectionList(rr::Ptr{Nothing}, list::String)
Set the selection list for output from simulate(void) or simulateEx(void). Use getAvailableTimeCourseSymbols(void) to retrieve the list of all possible symbols.
Example: setTimeCourseSelectionList ("Time, S1, J1, J2");
or setTimeCourseSelectionList ("Time S1 J1 J2")
"""
function setTimeCourseSelectionList(rr::Ptr{Nothing}, list::String)
  status = ccall(dlsym(rrlib, :setTimeCourseSelectionList), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, list)
  if status == false
    error(getLastError())
  end
end

## RRStringArray Helper
"""
    getTimeCourseSelectionList(rr::Ptr{Nothing})
Get the current selection list for simulate(void) or simulateEx(void).
"""
function getTimeCourseSelectionList(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getTimeCourseSelectionList), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end
"""
    simulate(rr::Ptr{Nothing})
Carry out a time-course simulation. setTimeStart, setTimeEnd, setNumPoints, etc are used to set the simulation characteristics.
"""
function simulate(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :simulate), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
  print(data)
  return simulate_helper(data)
end

## Handle RRCData
"""
    getSimulationResult(rr::Ptr{Nothing})
Retrieve the result of the last simulation.
"""
function getSimulationResult(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getSimulationResult), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
end

# calls simulateEx
"""
    simulate(rr::Ptr{Nothing}, startTime::Number, endTime::Number, steps::Int)
Carry out a time-course simulation. setTimeStart, setTimeEnd, setNumPoints, etc are used to set the simulation characteristics.
"""
function simulate(rr::Ptr{Nothing}, startTime::Number, endTime::Number, steps::Int)
  data = ccall(dlsym(rrlib, :simulateEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Cdouble, Cdouble, Cint), rr, startTime, endTime, steps)
  return simulate_helper(data)
end

function simulate_helper(data::Ptr{RRCData})
  num_row = getRRDataNumRows(data)
  num_col = getRRDataNumCols(data)
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
"""
    oneStep(rr::Ptr{Nothing}, currentTime::Float64, stepSize::Float64)
Carry out a one step integration of the model.
Example: status = OneStep (rrHandle, currentTime, timeStep, newTimeStep);
"""
function oneStep(rr::Ptr{Nothing}, currentTime::Float64, stepSize::Float64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :oneStep), cdecl, Bool, (Ptr{Nothing}, Float64, Float64, Ptr{Float64}), rr, currentTime, stepSize, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getTimeStart(rr::Ptr{Nothing})
Get the value of the current time start.
"""
function getTimeStart(rr::Ptr{Nothing})
  timeStart = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getTimeStart), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, timeStart)
  if status == false
    error(getLastError())
  end
  return timeStart[1]
end

"""
    getTimeEnd(rr::Ptr{Nothing})
Get the value of the current time end.
Example: status = getTimeEnd (rrHandle, &timeEnd);
"""
function getTimeEnd(rr::Ptr{Nothing})
  #timeEnd = Array(Float64, 1)
  timeEnd = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getTimeEnd), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, timeEnd)
  if status == false
    error(getLastError())
  end
  return timeEnd[1]
end

"""
    getNumPoints(rr)
Get the value of the current number of points.
Example: status = getNumPoints (rrHandle, &numberOfPoints);
"""
function getNumPoints(rr)
  numPoints = Array{Int64}(undef,1)
  status = ccall(dlsym(rrlib, :getNumPoints), cdecl, Bool, (Ptr{Nothing}, Ptr{Int64}), rr, numPoints)
  if status == false
    error(getLastError())
  end
  return numPoints[1]
end

###############################################################################
#                            Steady State Routines                            #
###############################################################################

"""
    steadyState(rr::Ptr{Nothing})
Compute the steady state of the current model.
Example: status = steadyState (rrHandle, &closenessToSteadyState);
"""
function steadyState(rr::Ptr{Nothing})
  value = Array{Float64}(undef, 1)
  status = ccall(dlsym(rrlib, :steadyState), cdecl, Bool, (Ptr{Nothing}, Ptr{Float64}), rr, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

## RRVectorHelper
"""
    computeSteadyStateValues(rr::Ptr{Nothing})
Compute the steady state of the current model.
Example: RRVectorHandle values = computeSteadyStateValues (void);
"""
function computeSteadyStateValues(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :computeSteadyStateValues), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end
"""
    setSteadyStateSelectionList(rr::Ptr{Nothing}, list::String)
Set the selection list of the steady state analysis.Use getAvailableTimeCourseSymbols(void) to retrieve the list of all possible symbols.
Example:  setSteadyStateSelectionList ("S1, J1, J2") or setSteadyStateSelectionList ("S1 J1 J2")
"""
function setSteadyStateSelectionList(rr::Ptr{Nothing}, list::String)
  status = ccall(dlsym(rrlib, :setSteadyStateSelectionList), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, list)
  if status == false
    error(getLastError())
  end
end

## RRStringArray Helper
## Attention Returns Null
"""
    getSteadyStateSelectionList(rr::Ptr{Nothing})
Get the selection list for the steady state analysis.
"""
function getSteadyStateSelectionList(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getSteadyStateSelectionList), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end

###############################################################################
#                               Reaction Group                                #
###############################################################################

"""
    getNumberOfReactions(rr::Ptr{Nothing})
Obtain the number of reactions in the loaded model. Example: number = getNumberOfReactions (RRHandle handle);
"""
function getNumberOfReactions(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfReactions), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
    getReactionRate(rr::Ptr{Nothing}, idx::Int64)
Retrieve a give reaction rate as indicated by the index paramete.
"""
function getReactionRate(rr::Ptr{Nothing}, idx::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getReactionRate), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, rateNr, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

### RRVector Helper
## Attention Returns NUll
"""
    getReactionRates(rr::Ptr{Nothing})
Retrieve a vector of reaction rates as determined by the current state of the model.
"""
function getReactionRates(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getReactionRates), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

### RRVector Helper
## Attention Returns Null

"""
    getReactionRatesEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Retrieve a vector of reaction rates given a vector of species concentrations.
"""
function getReactionRatesEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  return_vec = call(dlsym(rrlib, :getReactionRatesEx), cdecl, Ptr{RRVector}, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  return return_vec
end

## Attention Returns Null
"""
    getReactionIds(rr::Ptr{Nothing})
Obtain the list of reaction Ids.
"""
function getReactionIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getReactionIds), cdecl, Ptr{Nothing}, (Ptr{Nothing},), rr)
  num_rxns = getNumberOfReactions(rr)
  rxnIds = String[]
  try
    for i = 1:num_rxns
      push!(rxnIds, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return rxnIds
end

###############################################################################
#                            Rates of Change Group                            #
###############################################################################


### RRVector
## Attention Returns False
"""
    getRatesOfChange(rr::Ptr{Nothing})
RRetrieve the vector of rates of change as determined by the current state of the model.
Example: values = getRatesOfChange (RRHandle handle);
"""
function getRatesOfChange(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getRatesOfChange), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

### RRVector Helper
"""
    getRatesOfChange(rr::Ptr{Nothing})
Retrieve the rate of change for a given floating species.
Example: status = getRateOfChange (&index, *value);
"""
function getRatesOfChangeIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getRatesOfChangeIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end

"""
    getRatesOfChange(rr::Ptr{Nothing})
Retrieve the rate of change for a given floating species.
Example: status = getRateOfChange (&index, *value);
"""
function getRateOfChange(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib :getRateOfChange), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, inde, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

## RRVector Helper
## Attention Returns Null
"""
    getRatesOfChangeEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Retrieve the vector of rates of change given a vector of floating species concentrations.
Example: values = getRatesOfChangeEx (vector);
"""
function getRatesOfChangeEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  return ccall(dlsym(rrlib, :getRatesOfChangeEx), cdecl, Ptr{Nothing}, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
end

###############################################################################
#                           Boundary Species Group                            #
###############################################################################

## RRVectorHelper
## Attention Returns False
""""
    getBoundarySpeciesConcentrations(rr::Ptr{Nothing})
Retrieve the concentration for a particular floating species.
"""
function getBoundarySpeciesConcentrations(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getBoundarySpeciesConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

""""
    setBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the concentration for a particular boundary species.
"""
function setBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setBoundarySpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

""""
    getBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the concentration for a particular floating species.
"""
function getBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getBoundarySpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

## RRVectorHelper
""""
    setBoundarySpeciesConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Set the boundary species concentration to the vector vec.
Example:
    1 myVector = createVector (getNumberOfBoundarySpecies(RRHandle handle));
    2 setVectorElement (myVector, 0, 1.2);
    3 setVectorElement (myVector, 1, 5.7);
    4 setVectorElement (myVector, 2, 3.4);
    5 setBoundarySpeciesConcentrations(myVector);
"""
function setBoundarySpeciesConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  status = ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if status == false
    error(getLastError())
  end
""""
    getNumberOfBoundarySpecies(rr::Ptr{Nothing})
Returns the number of boundary species in the model.
"""
function getNumberOfBoundarySpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfBoundarySpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end
## Attention Returns Null
""""
    getBoundarySpeciesIds(rr::Ptr{Nothing})
Obtain the list of boundary species Ids.
"""
function getBoundarySpeciesIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getBoundarySpeciesIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  b_species = String[]
  try
    num_b_species = getNumberOfBoundarySpecies(rr)
    for i = 1:num_b_species
      push!(b_species, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return b_species
end

###############################################################################
#                           Floating Species Group                            #
###############################################################################

## RRVectorHelper

""""
    getFloatingSpeciesConcentrations(rr::Ptr{Nothing})
Retrieve in a vector the concentrations for all the floating species.
Example:  RVectorPtr values = getFloatingSpeciesConcentrations (void);
"""
function getFloatingSpeciesConcentrations(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getFloatingSpeciesConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

""""
    setFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the initial concentration for a particular floating species.
"""
function setFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = call(dlsym(rrlib, :setFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

## Attention Returns False
""""
    getFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64)
Get the initial concentration for a particular floating species.
"""
function getFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Floating64}(undef,1)
  status = ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

""""
    setFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the concentration for a particular floating species.
"""
function setFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setFloatingSpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

## Attention Returns False
""""
    getFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the concentration for a particular floating species.
"""
function getFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getFloatingSpeciesByIndex ), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end
""""
    setFloatingSpeciesConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Set the floating species concentration to the vector vec.
Example:
    1 myVector = createVector (getNumberOfFloatingSpecies(RRHandle handle));
    2 setVectorElement (myVector, 0, 1.2);
    3 setVectorElement (myVector, 1, 5.7);
    4 setVectorElement (myVector, 2, 3.4);
    5 setFloatingSpeciesConcentrations(myVector);
"""
function setFloatingSpeciesConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  status = ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if status == false
    error(getLastError())
  end
end

""""
    getNumberOfFloatingSpecies(rr::Ptr{Nothing})
Returns the number of floating species in the model.
"""
function getNumberOfFloatingSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfFloatingSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

""""
    getNumberOfDependentSpecies(rr::Ptr{Nothing})
Returns the number of dependent species in the mode.
"""
function getNumberOfDependentSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfDependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

""""
    getNumberOfIndependentSpecies(rr::Ptr{Nothing})
Returns the number of independent species in the model.
"""
function getNumberOfIndependentSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfIndependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

## Attention Returns Null
""""
    getFloatingSpeciesIds(rr::Ptr{Nothing})
Obtain the list of floating species Id.
"""
function getFloatingSpeciesIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getFloatingSpeciesIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  species = String[]
  try
    num_species = getNumberOfFloatingSpecies(rr)
    for i = 1:num_species
      push!(species, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return species
end

###############################################################################
#                           Intial Conditions Group                           #
###############################################################################

""""
    setFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Set the initial floating species concentrations.
Example: status = setFloatingSpeciesInitialConcentrations (vec);
"""
function setFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  status = ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if status == false
    error(getLastError())
  end
end

## RRVectorHelper
## Attention Returns Null
""""
    getFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing})
Get the initial floating species concentrations.
Example: vec = getFloatingSpeciesInitialConcentrations (RRHandle handle);
"""
function getFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end
## RRStringArrayHelper
## Attention Returns Null
""""
    getFloatingSpeciesInitialConditionIds(rr::Ptr{Nothing})
Get the initial floating species Ids.
Example: vec = getFloatingSpeciesInitialConditionIds (RRHandle handle);
"""
function getFloatingSpeciesInitialConditionIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getFloatingSpeciesInitialConditionIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  return data
end

###############################################################################
#                              Parameters Group                               #
###############################################################################

## RRVectorHelper
## Attention Returns False
""""
    getGlobalParameterValues(rr::Ptr{Nothing})
Retrieve the global parameter value.
Example: RRVectorPtr values = getGlobalParameterValues (void);
"""
function getGlobalParameterValues(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getGlobalParameterValues), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

""""
    setGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the value for a particular global parameter.
"""
function setGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setGlobalParameterByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end
""""
    getGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the global parameter value.
"""
function getGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getGlobalParameterByIndex ), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end
""""
    getNumberOfGlobalParameters(rr::Ptr{Nothing})
Returns the number of global parameters in the model.
"""
function getNumberOfGlobalParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfGlobalParameters), cdecl, Int64, (Ptr{Nothing},), rr)
end

## Attention Returns Null
""""
    getGlobalParameterIds(rr::Ptr{Nothing})
Obtain the list of global parameter Ids.
"""
function getGlobalParameterIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getGlobalParameterIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  global_params = String[]
  try
    num_elem = getNumberOfGlobalParameters(rr)
    for i = 1:num_elem
      push!(global_params, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return global_params
end

###############################################################################
#                              Compartment Group                              #
###############################################################################
""""
    getCompartmentByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the compartment volume for a particular compartment.
"""
function getCompartmentByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib :getCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end
""""
    setCompartmentByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the volume for a particular compartment.
"""
function setCompartmentByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

""""
    getNumberOfCompartments(rr::Ptr{Nothing})
Returns the number of compartments in the model.
"""
function getNumberOfCompartments(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfCompartments), cdecl, Int64, (Ptr{Nothing},), rr)
end

""""
    getCompartmentIds(rr::Ptr{Nothing})
Obtain the list of compartment Ids.
Example: str = getCompartmentIds (RRHandle handle);
"""
function getCompartmentIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getCompartmentIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  compartmentIds = String[]
  try
    num_elem = getNumberOfCompartments(rr)
    for i = 1:num_elem
      push!(compartmentIds, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return compartmentIds
end

###############################################################################
#                        Metabolic Control Analysis                           #
###############################################################################

## RRListHelper
function getElasticityCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getElasticityCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end

## RRListHelper
function getUnscaledFluxControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end


## RRListHelper
function getFluxControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getFluxControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end

## RRListHelper
function getUnscaledConcentrationControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end

## RRListHelper
function getConcentrationControlCoefficientIds(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getConcentrationControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getUnscaledElasticityMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledElasticityMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getScaledElasticityMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getScaledElasticityMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end


function getScaledFloatingSpeciesElasticity(rr::Ptr{Nothing}, reactionId::String, speciesId::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getScaledFloatingSpeciesElasticity), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, reactionId, speciesId, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

## RRDoubleMatrixHelper
function getUnscaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getScaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getScaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getUnscaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getScaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getScaledFluxControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
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

###############################################################################
#                           Stochastic Simulation                             #
###############################################################################

function getSeed(rr::Ptr{Nothing})
  value = Array{Float32}(undef,1)
  status = ccall(dlsym(rrlib, :getSeed), cdecl, Bool, (Ptr{Nothing}, Ptr{Float32}), rr, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function setSeed(rr::Ptr{Nothing}, result::Float32)
  status = ccall(dlsym(rrlib, :setSeed), cdecl, Bool, (Ptr{Nothing}, Float32), rr, result)
  if status == false
    error(getLastError())
  end
end

## RRCDataHelper
function gillespie(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :gillespie), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
end

## RRCDataHelper
function gillespieEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64)
  return ccall(dlsym(rrlib, :gillespieEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64), rr, timeStart, timeEnd)
end

## RRCDataHelper
function gillespieOnGrid(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :gillespieOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
end

## RRCDataHelper
function gillespieOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64)
  return ccall(dlsym(rrlib, :gillespieOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64), rr, timeStart, timeEnd, numberOfPoints)
end

## RRCDataHelper
function gillespieMeanOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
end

## RRCDataHelper
function gillespieMeanOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
end

## RRCDataHelper
function gillespieMeanSDOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanSDOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
end

## RRCDataHelper
function gillespieMeanSDOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  return ccall(dlsym(rrlib, :gillespieMeanSDOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
end

###############################################################################
#                           Stoichiometry Analysis                            #
###############################################################################

## RRDoubleMatrixHelper
function getFullJacobian(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getFullJacobian), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getReducedJacobian(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getReducedJacobian), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getEigenvalues(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getEigenvalues), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getStoichiometryMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getStoichiometryMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getLinkMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getLinkMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getNrMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNrMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getConservationMatrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getConservationMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRDoubleMatrixHelper
function getL0Matrix(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getL0Matrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
end

## RRComplexMatrixHelper
function getEigenVectors(matrix::Ptr{RRComplexMatrix})
  return ccall(dlsym(rrlib, :getEigenVectors), cdecl, Ptr{RRComplexMatrix}, (Ptr{RRComplexMatrix},), rr)
end

## RRComplexMatrixHelper
function getZEigenVectors(matrix::Ptr{RRComplexMatrix})
  return ccall(dlsym(rrlib, :getZEigenVectors), cdecl, Ptr{RRComplexMatrix}, (Ptr{RRComplexMatrix},), rr)
end

## RRVector
function getConservedSums(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getConservedSums), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
end

###############################################################################
#                      Network Object Model Functions                         #
###############################################################################

function getNumberOfRules(rr::Ptr{Nothing})
  result = ccall(dlsym(rrlib, :getConservedSums), cdecl, Cint, (Ptr{Nothing},), rr)
  if result == -1
    error(getLastError())
  end
end

## could return null, error checking
function getModelName(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getModelName), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

###############################################################################
#                           Linear Algebra Functions                          #
###############################################################################
## RRDoubleMatrixHelper
function getEigenvaluesMatrix(mat::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getEigenvaluesMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{RRDoubleMatrix},), rr)
end

## RRComplexVectorHelper
function getEigenvaluesVector(mat::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getEigenvaluesVector), cdecl, Ptr{RRComplexVector}, (Ptr{RRDoubleMatrix},), rr)
end

###############################################################################
#                               Reset Methods                                 #
###############################################################################
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

###############################################################################
#                          Solver Options and APIs                            #
###############################################################################

function getNumRegisteredIntegrators()
  return ccall(dlsym(rrlib, :getNumRegisteredIntegrators), cdecl, Cint, ())
end

function getRegisteredIntegratorName(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredIntegratorName), cdecl, Ptr{UInt8}, (Cint,), n))
end

function getRegisteredIntegratorHint(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredIntegratorHint), cdecl, Ptr{UInt8}, (Cint,), n))
end

function getRegisteredIntegratorDescription(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredIntegratorDescription), cdecl, Ptr{UInt8}, (Cint,), n))
end

function getNumInstantiatedIntegrators(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumInstantiatedIntegrators), cdecl, Cint, (Ptr{Nothing},), rr)
end

function setCurrentIntegrator(rr::Ptr{Nothing}, nameOfIntegrator::String)
  result = ccall(dlsym(rrlib, :setCurrentIntegrator), cdecl, Cint, (Ptr{Nothing}, String), rr, nameOfIntegrator)
  if result == 0
    error(getLastError())
  end
end

function getCurrentIntegratorName(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorName), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getCurrentIntegratorDescription(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getCurrentIntegratorHint(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorHint), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr))
end

function getNumberOfCurrentIntegratorParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfCurrentIntegratorParameters), cdecl, Cint, (Ptr{Nothing}, ), rr)
end

function getCurrentIntegratorNthParameterName(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentIntegratorNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentIntegratorNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterDisplayName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentIntegratorNthParameterHint(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentIntegratorNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

function resetCurrentIntegratorParameters(rr::Ptr{Nothing})
  result = ccall(dlsym(rrlib, :resetCurrentIntegratorParameters), cdecl, Cint, (Ptr{Nothing},), rr)
  if result == 0
    error(getLastError())
  end
end

## RRStringArrayHelper
function getListOfCurrentIntegratorParameterNames(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getListOfCurrentIntegratorParameterNames), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
end

function getCurrentIntegratorParameterDescription(rr::Ptr{Nothing}, parameterName::String)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName))
end

function getCurrentIntegratorParameterHint(rr::Ptr{Nothing}, parameterName::String)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName))
end

function getCurrentIntegratorParameterType(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterType), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function getCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  return ccall(dlsym(rrlib, :setCurrentIntegratorParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
end

function getCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterUInt), cdecl, Cuint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterUInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterUInt), cdecl, Cdouble, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterUInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentIntegratorParameterString), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName))
end

function setCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
  status = ccall(dlsym(rrlib, :getCurrentIntegratorParameterString), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterUInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getNumRegisteredSteadyStateSolvers()
  return ccall(dlsym(rrlib, :getNumRegisteredIntegrators), cdecl, Cint, ())
end

function getRegisteredSteadyStateSolverName(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverName), cdecl, Ptr{UInt8}, (Cint, ), n))
end

function getRegisteredSteadyStateSolverHint(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverHint), cdecl, Ptr{UInt8}, (Cint, ), n))
end

function getRegisteredSteadyStateSolverDescription(n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverDescription), cdecl, Ptr{UInt8}, (Cint, ), n))
end

function setCurrentSteadyStateSolver(rr::Ptr{Nothing}, nameOfSteadyStateSolver::String)
  status = ccall(dlsym(rrlib, :getNumRegisteredIntegrators), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, nameOfSteadyStateSolver)
  if status == 0
    error(getLastError())
  end
end

function getCurrentSteadyStateSolverName(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr))
end

function getCurrentSteadyStateSolverDescription(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr))
end

function getCurrentSteadyStateSolverHint(rr::Ptr{Nothing})
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr))
end

function getNumberOfCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverHint), cdecl, Cint, (Ptr{Nothing}, ), rr)
end

function getCurrentSteadyStateSolverNthParameterName(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentSteadyStateSolverNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterDisplayName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentSteadyStateSolverNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentSteadyStateSolverNthParameterHint(rr::Ptr{Nothing}, n::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n))
end

function getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

function resetCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :resetCurrentSteadyStateSolverParameters), cdecl, Cint, (Ptr{Nothing},), rr)
  if status == 0
    error(getLastError())
  end
end

function solverTypeToString(code::Int64)
  return unsafe_string(ccall(dlsym(rrlib, :solverTypeToString), cdecl, Ptr{UInt8}, (Cint, ), code))
end

function getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

## RRString helper function
function getListOfCurrentSteadyStateSolverParameterNames(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getListOfCurrentSteadyStateSolverParameterNames), cdecl, Ptr{RRStringArray}, (Ptr{Nothing}, ), rr)
end

function getCurrentSteadyStateSolverParameterDescription(rr::Ptr{Nothing}, parameterName::String)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName))
end

function getCurrentSteadyStateSolverParameterHint(rr::Ptr{Nothing}, parameterName::String)
  return unsafe_string(ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName))
end

function getCurrentSteadyStateSolverParameterType(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterType), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function getCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterUInt), cdecl, Cuint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterUInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterUInt), cdecl, Cdouble, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterDouble), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterString), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterString), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

function getCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

function setCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

###############################################################################
#                        Configuration Keys and Values                        #
###############################################################################

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

function getParamPromotedSBML(rr::Ptr{Nothing}, sArg::String)
  return unsafe_string(ccall(dlsym(rrlib, :getParamPromotedSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, sArg))
end

end # module
