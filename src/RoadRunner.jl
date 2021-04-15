module RoadRunner
__precompile__(false)
#export my_f(x,y), another function to export

using Libdl


current_dir = @__DIR__
rr_api = joinpath(current_dir, "roadrunner_c_api.dll")
antimony_api = joinpath(current_dir, "libantimony.dll")
rrlib = Ptr{Nothing}
antlib = Ptr{Nothing}

include("rrc_utilities_binding.jl")
include("antimony_binding.jl")
include("rrc_types.jl")

@enum CLogLevel CL_PRIO_FATAL CL_PRIO_CRITICAL CL_PRIO_ERROR CL_PRIO_WARNING CL_PRIO_NOTICE CL_PRIO_INFORMATION CL_PRIO_DEBUG CL_PRIO_TRACE

function __init__()
    @static if Sys.iswindows()
        global rrlib = Libdl.dlopen(rr_api)
        global antlib = Libdl.dlopen(antimony_api)
    else
        @warn "The current version of RoadRunner.jl only supports the platform of Windows x64."
    end
end


"""
    loada(antString::String)
Take an antimony string and return a roadrunner instance
"""
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
Return the folder in which the RoadRunner API is installed.
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
  status = ccall(dlsym(rrlib, :loadSimulationSettings), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileName)
  if status == false
    error(getLastError())
  end
end

"""
    getCurrentSBM(handle::Ptr{Nothing})
Retrieve the current state of the model in the form of an SBML string.
"""
function getCurrentSBML(rr)
  char_pointer=ccall(dlsym(rrlib, :getCurrentSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str=unsafe_string(char_pointer)
  return julia_str
end

"""
    getSBML(rr::Ptr{Nothing})
Retrieve the SBML model that was last loaded into roadRunner.
"""
function getSBML(rr)
  char_pointer=ccall(dlsym(rrlib, :getSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str=unsafe_string(char_pointer)
  return julia_str
end

###############################################################################
#                          Utilities Functions                               #
###############################################################################
"""
    getAPIVersion()
Retrieve the current version number of the C API library.
"""
function getAPIVersion()
  char_pointer = ccall(dlsym(rrlib, :getAPIVersion), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCPPAPIVersion(rr::Ptr{Nothing})
Retrieve the current version number of the C++ API (Core RoadRunner API) library..
"""
function getCPPAPIVersion(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCPPAPIVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getVersion()
Get the version number.
Return the roadrunner version number in the form or 102030 if the number is 1.2.3
return the individual version numbers as XXYYZZ where XX is the major version, YY the minor and ZZ the revision, eg 10000, or 10100, 20000 etc
"""
function getVersion()
  return ccall(dlsym(rrlib, :getVersion), cdecl, Int64, ())
end

"""
    getVersionStr()
return roadrunner as a string, i.e. "1.0.0"
"""
function getVersionStr()
  char_pointer = ccall(dlsym(rrlib, :getVersionStr), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getVersionEx()
return something like "1.0.0; compiled with clang "3.3 (tags/RELEASE_33/final)" on date Dec 8 2013, 17:24:57'
"""
function getVersionEx()
  char_pointer = ccall(dlsym(rrlib, :getVersionEx), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getExtendedAPIInfo()
Retrieve extended API info. Returns null if it fails, otherwise it returns a string with the info.
"""
function getExtendedAPIInfo()
  char_pointer = ccall(dlsym(rrlib, :getExtendedAPIInfo), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getBuildDate()
Retrieve the current build date of the library.
"""
function getBuildDate()
  char_pointer = ccall(dlsym(rrlib, :getBuildDate), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getBuildTime()
Retrieve the current build time (HH:MM:SS) of the library.
"""
function getBuildTime()
  char_pointer = ccall(dlsym(rrlib, :getBuildTime), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getBuildDateTime()
Retrieve the current build date + time of the library.
"""
function getBuildDateTime()
  char_pointer = ccall(dlsym(rrlib, :getBuildDateTime), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCopyright()
Retrieve the current copyright notice for the library.
"""
function getCopyright()
  char_pointer = ccall(dlsym(rrlib, :getCopyright), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getInfo(rr::Ptr{Nothing})
Retrieve the current version number of the libSBML library.
"""
function getInfo(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getInfo), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getlibSBMLVersion(rr::Ptr{Nothing})
Retrieve info about current state of roadrunner, e.g. loaded model, conservationAnalysis etc.
"""
function getlibSBMLVersion(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getlibSBMLVersion), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
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

"""
    getTempFolder(rr::Ptr{Nothing})
Retrieve the current temporary folder path. When RoadRunner is run in C generation mode it uses a temporary folder to store the generate C source code. This method can be used to get the current value for the temporary folder path.
"""
function getTempFolder(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getTempFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getWorkingDirectory()
Retrieve the current working directory path.
"""
function getWorkingDirectory()
  char_pointer = ccall(dlsym(rrlib, :getWorkingDirectory), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getRRCAPILocation()
Retrieve the directory path of the shared rrCApi library.
"""
function getRRCAPILocation()
  char_pointer = ccall(dlsym(rrlib, :getRRCAPILocation), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
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
  char_pointer = ccall(dlsym(rrlib, :getCompiler), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
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

"""
    getCompilerLocation(rr::Ptr{Nothing})
Get the path to a folder containing the compiler being used. Returns the path if successful, NULL otherwise
"""
function getCompilerLocation(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCompilerLocation), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
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

"""
    getSupportCodeFolder(rr::Ptr{Nothing})
Get the path to a folder containing support code.
"""
function getSupportCodeFolder(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getSupportCodeFolder), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
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
"""
    hasError()
Check if there is an error string to retrieve. Example: status = hasError (void)
"""
function hasError()
  return ccall(dlsym(rrlib, :hasError), cdecl, Bool, ())
end

"""
    getLastError()
Retrieve the current error string. Example, str = getLastError (void);
"""
function getLastError()
  char_pointer = ccall(dlsym(rrlib, :getLastError), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
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
  status = ccall(dlsym(rrlib, :enableLoggingToFileWithPath), cdecl, Bool, (Ptr{UInt8},), path)
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

"""
    setLogLevel(lvl::String)
Set the logging status level The logging level is determined by the following strings.
"ANY", "DEBUG5", "DEBUG4", "DEBUG3", "DEBUG2", "DEBUG1", "DEBUG", "INFO", "WARNING", "ERROR"
Example: setLogLevel ("DEBUG4")
"""
function setLogLevel(lvl::String)
  return ccall(dlsym(rrlib, :setLogLevel), cdecl, Int8, (Ptr{UInt8},), lvl)
end

"""
    getLogLevel()
Get the logging status level as a pointer to a string. The logging level can be one of the following strings
"ANY", "DEBUG5", "DEBUG4", "DEBUG3", "DEBUG2", "DEBUG1", "DEBUG", "INFO", "WARNING", "ERROR"
Example str = getLogLevel (void)
"""
function getLogLevel()
  char_pointer = ccall(dlsym(rrlib, :getLogLevel), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getLogFileName()
Get a pointer to the string that holds the logging file name path. Example: str = getLogFileName (void)
"""
function getLogFileName()
  char_pointer = ccall(dlsym(rrlib, :getLogFileName), cdecl, Ptr{UInt8}, ())
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    logMsg()
Create a log message.
"""
function logMsg(lvl, msg)
  return ccall(dlsym(rrlib, :logMsg), cdecl, Bool, (CLogLevel, Ptr{UInt8}), lvl, msg)
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
  list = ccall(dlsym(rrlib, :getAvailableTimeCourseSymbols), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getAvailableSteadyStateSymbols(rr::Ptr{Nothing})
Obtain the list of all available steady state symbols.
"""
function getAvailableSteadyStateSymbols(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getAvailableSteadyStateSymbols), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
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
end

"""
    getConfigurationXML(rr::Ptr{Nothing})
Get the simulator's capabilities.
"""
function getConfigurationXML(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getConfigurationXML), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
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

"""
    getTimeCourseSelectionList(rr::Ptr{Nothing})
Get the current selection list for simulate(void) or simulateEx(void).
"""
function getTimeCourseSelectionList(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getTimeCourseSelectionList), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
end

"""
    getSimulationResult(rr::Ptr{Nothing})
Retrieve the result of the last simulation.
"""
function getSimulationResult(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getSimulationResult), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
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
    simulateEx(rr::Ptr{Nothing}, startTime::Number, endTime::Number, setNumPoints::Int)
Carry out a time-course simulation based on the given arguments, time start, time end and number of points.
"""
function simulateEx(rr::Ptr{Nothing}, startTime::Number, endTime::Number, setNumPoints::Int64)
  data = ccall(dlsym(rrlib, :simulateEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Cdouble, Cdouble, Cint), rr, startTime, endTime, setNumPoints)
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
    simulate(rr::Ptr{Nothing})
Carry out a time-course simulation. setTimeStart, setTimeEnd, setNumPoints, etc are used to set the simulation characteristics.
"""
# time start from 0, the first column is time and the other colums are for floating species
function simulate(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :simulate), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
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
  status = ccall(dlsym(rrlib, :setSteadyStateSelectionList), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, list)
  if status == false
    error(getLastError())
  end
end

"""
    getSteadyStateSelectionList(rr::Ptr{Nothing})
Get the selection list for the steady state analysis.
"""
function getSteadyStateSelectionList(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getSteadyStateSelectionList), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
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
function getReactionRate(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getReactionRate), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getReactionRates(rr::Ptr{Nothing})
Retrieve a vector of reaction rates as determined by the current state of the model.
"""
function getReactionRates(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getReactionRates), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    getReactionRatesEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
Retrieve a vector of reaction rates given a vector of species concentrations.
"""
function getReactionRatesEx(rr::Ptr{Nothing}, vec::Ptr{RRVector})
  rrVector = ccall(dlsym(rrlib, :getReactionRatesEx), cdecl, Ptr{RRVector}, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    getReactionIds(rr::Ptr{Nothing})
Obtain the list of reaction Ids.
"""
function getReactionIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getReactionIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
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
"""
    getRatesOfChange(rr::Ptr{Nothing})
Retrieve the vector of rates of change as determined by the current state of the model.
Example: values = getRatesOfChange (RRHandle handle);
"""
function getRatesOfChange(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getRatesOfChange), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    getRatesOfChange(rr::Ptr{Nothing})
Retrieve the rate of change for a given floating species.
Example: status = getRateOfChange (&index, *value);
"""
function getRatesOfChangeIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getRatesOfChangeIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
end

"""
    getRatesOfChange(rr::Ptr{Nothing}, index::Int64)
Retrieve the rate of change for a given floating species.
Example: status = getRateOfChange (&index, *value);
"""
function getRateOfChange(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib :getRateOfChange), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

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

"""
    getBoundarySpeciesConcentrations(rr::Ptr{Nothing})
Retrieve the concentration for a particular floating species.
"""
function getBoundarySpeciesConcentrations(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getBoundarySpeciesConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    setBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the concentration for a particular boundary species.
"""
function setBoundarySpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setBoundarySpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

"""
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

"""
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
  status = ccall(dlsym(rrlib, :setBoundarySpeciesConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if status == false
    error(getLastError())
  end
end

"""
    getNumberOfBoundarySpecies(rr::Ptr{Nothing})
Return the number of boundary species in the model.
"""
function getNumberOfBoundarySpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfBoundarySpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
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
"""
    getFloatingSpeciesConcentrations(rr::Ptr{Nothing})
Retrieve in a vector the concentrations for all the floating species.
Example:  RVectorPtr values = getFloatingSpeciesConcentrations (void);
"""
function getFloatingSpeciesConcentrations(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getFloatingSpeciesConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    setFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the initial concentration for a particular floating species.
"""
function setFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
  return status
end

"""
    getFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64)
Get the initial concentration for a particular floating species.
"""
function getFloatingSpeciesInitialConcentrationByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrationByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the concentration for a particular floating species.
"""
function setFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setFloatingSpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

"""
    getFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the concentration for a particular floating species.
"""
function getFloatingSpeciesByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getFloatingSpeciesByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
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
  status = ccall(dlsym(rrlib, :setFloatingSpeciesConcentrations), cdecl, Bool, (Ptr{Nothing}, Ptr{RRVector}), rr, vec)
  if status == false
    error(getLastError())
  end
end

"""
    getNumberOfFloatingSpecies(rr::Ptr{Nothing})
Return the number of floating species in the model.
"""
function getNumberOfFloatingSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfFloatingSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
    getNumberOfDependentSpecies(rr::Ptr{Nothing})
Return the number of dependent species in the mode.
"""
function getNumberOfDependentSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfDependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
    getNumberOfIndependentSpecies(rr::Ptr{Nothing})
Return the number of independent species in the model.
"""
function getNumberOfIndependentSpecies(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfIndependentSpecies), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
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
"""
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

"""
    getFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing})
Get the initial floating species concentrations.
Example: vec = getFloatingSpeciesInitialConcentrations (RRHandle handle);
"""
function getFloatingSpeciesInitialConcentrations(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getFloatingSpeciesInitialConcentrations), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    getFloatingSpeciesInitialConditionIds(rr::Ptr{Nothing})
Get the initial floating species Ids.
Example: vec = getFloatingSpeciesInitialConditionIds (RRHandle handle);
"""
function getFloatingSpeciesInitialConditionIds(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getFloatingSpeciesInitialConditionIds), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
end

###############################################################################
#                              Parameters Group                               #
###############################################################################
"""
    getGlobalParameterValues(rr::Ptr{Nothing})
Retrieve the global parameter value.
Example: RRVectorPtr values = getGlobalParameterValues (void);
"""
function getGlobalParameterValues(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getGlobalParameterValues), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

"""
    setGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the value for a particular global parameter.
"""
function setGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setGlobalParameterByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

"""
    getGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the global parameter value.
"""
function getGlobalParameterByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getGlobalParameterByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getNumberOfGlobalParameters(rr::Ptr{Nothing})
Return the number of global parameters in the model.
"""
function getNumberOfGlobalParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfGlobalParameters), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
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
"""
    getCompartmentByIndex(rr::Ptr{Nothing}, index::Int64)
Retrieve the compartment volume for a particular compartment.
"""
function getCompartmentByIndex(rr::Ptr{Nothing}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Ptr{Float64}), rr, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setCompartmentByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
Set the volume for a particular compartment.
"""
function setCompartmentByIndex(rr::Ptr{Nothing}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setCompartmentByIndex), cdecl, Bool, (Ptr{Nothing}, Int64, Float64), rr, index, value)
  if status == false
    error(getLastError())
  end
end

"""
    getNumberOfCompartments(rr::Ptr{Nothing})
Return the number of compartments in the model.
"""
function getNumberOfCompartments(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfCompartments), cdecl, Int64, (Ptr{Nothing},), rr)
end

"""
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
"""
    getElasticityCoefficientIds(rr::Ptr{Nothing})
Obtain the list of elasticity coefficient Ids.
"""
function getElasticityCoefficientIds(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getElasticityCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getUnscaledFluxControlCoefficientIds(rr::Ptr{Nothing})
Obtain the list of unscaled flux control coefficient Ids.
"""
function getUnscaledFluxControlCoefficientIds(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getFluxControlCoefficientIds(rr::Ptr{Nothing})
Obtain the list of flux control coefficient Ids.
"""
function getFluxControlCoefficientIds(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getFluxControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getUnscaledConcentrationControlCoefficientIds(rr::Ptr{Nothing})
Obtain the list of unscaled concentration control coefficient Ids.
"""
function getUnscaledConcentrationControlCoefficientIds(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getConcentrationControlCoefficientIds(rr::Ptr{Nothing})
Obtain the list of concentration coefficient Ids.
"""
function getConcentrationControlCoefficientIds(rr::Ptr{Nothing})
  list = ccall(dlsym(rrlib, :getConcentrationControlCoefficientIds), cdecl, Ptr{RRList}, (Ptr{Nothing},), rr)
  result = listToString(list)
  freeRRList(list)
  return result
end

"""
    getUnscaledElasticityMatrix(rr::Ptr{Nothing})
Retrieve the unscaled elasticity matrix for the current model.
"""
function getUnscaledElasticityMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getUnscaledElasticityMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getScaledElasticityMatrix(rr::Ptr{Nothing})
Retrieve the scaled elasticity matrix for the current model.
"""
function getScaledElasticityMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getScaledElasticityMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getScaledFloatingSpeciesElasticity(rr::Ptr{Nothing}, reactionId::String, speciesId::String)
Retrieve the scaled elasticity matrix for the current model.
"""
function getScaledFloatingSpeciesElasticity(rr::Ptr{Nothing}, reactionId::String, speciesId::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getScaledFloatingSpeciesElasticity), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, reactionId, speciesId, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getUnscaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
Retrieve the matrix of unscaled concentration control coefficients for the current model.
"""
function getUnscaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getUnscaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getScaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
Retrieve the matrix of scaled concentration control coefficients for the current model.
"""
function getScaledConcentrationControlCoefficientMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getScaledConcentrationControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getUnscaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
Retrieve the matrix of unscaled flux control coefficients for the current model.
"""
function getUnscaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getUnscaledFluxControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
  end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getScaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
Retrieve the matrix of scaled flux control coefficients for the current model.
"""
function getScaledFluxControlCoefficientMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getScaledFluxControlCoefficientMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
  end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getuCC(rr::Ptr{Nothing}, variable::String, parameter::String)
Retrieve a single unscaled control coefficient.
"""
function getuCC(rr::Ptr{Nothing}, variable::String, parameter::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getuCC), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, variable, parameter, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getCC(rr::Ptr{Nothing}, variable::String, parameter::String)
Retrieve a single control coefficient.
"""
function getCC(rr::Ptr{Nothing}, variable::String, parameter::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getCC), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, variable, parameter, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getEE(rr::Ptr{Nothing}, name::String, species::String)
Retrieve a single elasticity coefficient.
"""
function getEE(rr::Ptr{Nothing}, name::String, species::String)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getEE), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{Float64}), rr, name, species, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getuEE(rr::Ptr{Nothing}, name::String, species::String)
Retrieve a single unscaled elasticity coefficient.
"""
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
"""
    getSeed(rr::Ptr{Nothing})
Determine the current seed used by the random generator.
"""
function getSeed(rr::Ptr{Nothing})
  value = Array{Float32}(undef,1)
  status = ccall(dlsym(rrlib, :getSeed), cdecl, Bool, (Ptr{Nothing}, Ptr{Float32}), rr, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setSeed(rr::Ptr{Nothing}, result::Int64)
Determine the current seed used by the random generator.
"""
function setSeed(rr::Ptr{Nothing}, result::Int64)
  status = ccall(dlsym(rrlib, :setSeed), cdecl, Bool, (Ptr{Nothing}, Int64), rr, result)
  if status == false
    error(getLastError())
  end
end

"""
    gillespie(rr::Ptr{Nothing})
Carry out a time-course simulation using the Gillespie algorithm with variable step size. setTimeStart, setTimeEnd, etc are used to set the simulation characteristics.
"""
function gillespie(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :gillespie), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
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
    gillespieEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64)
Carry out a time-course simulation using the Gillespie algorithm with variable step size. setTimeStart, setTimeEnd, etc are used to set the simulation characteristics.
"""
function gillespieEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64)
  data = ccall(dlsym(rrlib, :gillespieEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64), rr, timeStart, timeEnd)
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
    gillespieOnGrid(rr::Ptr{Nothing})
Carry out a time-course simulation using the Gillespie algorithm based on the given arguments, time start, time end and number of points.
Example:
    1 RRCDataPtr m;
    2 double timeStart = 0.0;
    3 double timeEnd = 25;
    4 m = gillespieEx (rrHandle, timeStart, timeEnd);
"""
function gillespieOnGrid(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :gillespieOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing},), rr)
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
    gillespieOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64)
Carry out a time-course simulation using the Gillespie algorithm with fixed step size based on the given arguments, time start, time end, and number of points.
Example:
    1 RRCDataPtr m;
    2 double timeStart = 0.0;
    3 double timeEnd = 25;
    4 int numberOfPoints = 200;
    5 m = gillespieOnGridEx (rrHandle, timeStart, timeEnd, numberOfPoints);
"""
function gillespieOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64)
  data = ccall(dlsym(rrlib, :gillespieOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64), rr, timeStart, timeEnd, numberOfPoints)
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
    gillespieMeanOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
Carry out a series of time-course simulations using the Gillespie algorithm with fixed step size, then return the average of the simulations.
setTimeStart, setTimeEnd, setNumPoints, etc are used to set the simulation characteristics.
"""
function gillespieMeanOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  data = ccall(dlsym(rrlib, :gillespieMeanOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
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
    gillespieMeanOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
Carry out a series of time-course simulations using the Gillespie algorithm with fixed step size, then return the average of the simulations.
Based on the given arguments, time start, time end, and number of points.
Example:
    1 RRCDataPtr m;
    2 double timeStart = 0.0;
    3 double timeEnd = 25;
    4 int numberOfPoints = 200;
    5 int numberOfSimulations = 10;
    6 m = gillespieMeanOnGridEx (rrHandle, timeStart, timeEnd, numberOfPoints, numberOfSimulations);
"""
function gillespieMeanOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  data = ccall(dlsym(rrlib, :gillespieMeanOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
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
    gillespieMeanSDOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
Carry out a series of time-course simulations using the Gillespie algorithm with fixed step size, then return the average and standard deviation of the simulations.
setTimeStart, setTimeEnd, setNumPoints, etc are used to set the simulation characteristics.
"""
function gillespieMeanSDOnGrid(rr::Ptr{Nothing}, numberOfSimulations::Int64)
  data = ccall(dlsym(rrlib, :gillespieMeanSDOnGrid), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Int64), rr, numberOfSimulations)
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
    gillespieMeanSDOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
Carry out a series of time-course simulations using the Gillespie algorithm with fixed step size, then return the average and standard deviation of the simulations.
Based on the given arguments, time start, time end, number of points, and number of simulations.
Example:
    1 RRCDataPtr m;
    2 double timeStart = 0.0;
    3 double timeEnd = 25;
    4 int numberOfPoints = 200;
    5 int numberOfSimulations = 10;
    6 m = gillespieMeanSDOnGridEx (rrHandle, timeStart, timeEnd, numberOfPoints, numberOfSimulations);
"""
function gillespieMeanSDOnGridEx(rr::Ptr{Nothing}, timeStart::Float64, timeEnd::Float64, numberOfPoints::Int64, numberOfSimulations::Int64)
  data = ccall(dlsym(rrlib, :gillespieMeanSDOnGridEx), cdecl, Ptr{RRCData}, (Ptr{Nothing}, Float64, Float64, Int64, Int64), rr, timeStart, timeEnd, numberOfPoints, numberOfSimulations)
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

###############################################################################
#                           Stoichiometry Analysis                            #
###############################################################################

"""
    getFullJacobian(rr::Ptr{Nothing})
Retrieve the full Jacobian for the current model.
"""
function getFullJacobian(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getFullJacobian), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getReducedJacobian(rr::Ptr{Nothing})
Retrieve the reduced Jacobian for the current model. setComputeAndAssignConservationLaws (true) must be enabled
"""
function getReducedJacobian(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getReducedJacobian), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getEigenvalues(rr::Ptr{Nothing})
Retrieve the eigenvalue matrix for the current model.
"""
function getEigenvalues(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getEigenvalues), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getStoichiometryMatrix(rr::Ptr{Nothing})
Retrieve the stoichiometry matrix for the current model.
"""
function getStoichiometryMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getStoichiometryMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getLinkMatrix(rr::Ptr{Nothing})
Retrieve the Link matrix for the current model.
"""
function getLinkMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getLinkMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getNrMatrix(rr::Ptr{Nothing})
Retrieve the reduced stoichiometry matrix for the current model.
"""
function getNrMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getNrMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getConservationMatrix(rr::Ptr{Nothing})
Retrieve the conservation matrix for the current model.
The conservation laws as describe by row where the columns indicate the species Id.
"""
function getConservationMatrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getConservationMatrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getL0Matrix(rr::Ptr{Nothing})
Return the L0 Matrix. L0 is defined such that L0 Nr = N0. L0 forms part of the link matrix, L.
N0 is the set of linear dependent rows from the lower portion of the reordered stoichiometry matrix.
"""
function getL0Matrix(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getL0Matrix), cdecl, Ptr{RRDoubleMatrix}, (Ptr{Nothing},), rr)
  num_row = getMatrixNumRows(data)
  num_col = getMatrixNumCols(data)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
      for c = 1:num_col
          data_arr[r, c] = getMatrixElement(data, r - 1, c - 1)
      end
    end
  catch e
    throw(e)
  finally
    freeMatrix(data)
  end
  return data_arr
end

"""
    getEigenVectors(matrix::Ptr{RRDoubleMatrix})
Calculate the eigen-vectors of a square real matrix. This function calculates the complex (right)eigenvectors of the given real matrix.
The complex matrix returned contains the eigenvectors in the columns, in the same order as LibLA_getEigenValues.
The right eigenvector v(j) of A satisfies: A * v(j) = lambda(j) * v(j)
"""
function getEigenVectors(matrix::Ptr{RRDoubleMatrix})
  data = ccall(dlsym(rrlib, :getEigenVectors), cdecl, Ptr{RRComplexMatrix}, (Ptr{RRDoubleMatrix},), matrix)
  num_row = getMatrixNumRows(matrix)
  num_col = getMatrixNumCols(matrix)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getComplexMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  end
  return data_arr
end

"""
    getZEigenVectors(matrix::Ptr{RRComplexMatrix})
Calculate the eigen-vectors of a square nonsymmetrix complex matrix. This function calculates the complex (right)eigenvectors of the given real matrix.
The complex matrix returned contains the eigenvectors in the columns, in the same order as getZEigenValues. The right eigenvector v(j) of A satisfies:
A * v(j) = lambda(j) * v(j)
"""
function getZEigenVectors(matrix::Ptr{RRComplexMatrix})
  data = ccall(dlsym(rrlib, :getZEigenVectors), cdecl, Ptr{RRComplexMatrix}, (Ptr{RRComplexMatrix},), matrix)
  num_row = getMatrixNumRows(matrix)
  num_col = getMatrixNumCols(matrix)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getComplexMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  end
  return data_arr
end

"""
    getConservedSums(rr::Ptr{Nothing})
Return values for conservation laws using the current initial conditions.
"""
function getConservedSums(rr::Ptr{Nothing})
  rrVector = ccall(dlsym(rrlib, :getConservedSums), cdecl, Ptr{RRVector}, (Ptr{Nothing},), rr)
  if rrVector == C_NULL
    error(getLastError())
  else
    ssValues = convertRRVectorToJuliaArray(rrVector)
    return ssValues
  end
end

###############################################################################
#                      Network Object Model Functions                         #
###############################################################################

"""
    getNumberOfRules(rr::Ptr{Nothing})
Return the number of rules in the current model.
"""
function getNumberOfRules(rr::Ptr{Nothing})
  result = ccall(dlsym(rrlib, :getNumberOfRules), cdecl, Cint, (Ptr{Nothing},), rr)
  if result == -1
    error(getLastError())
  end
  return result
end

"""
    getModelName(rr::Ptr{Nothing})
Return the name of currently loaded SBML model.
"""
function getModelName(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getModelName), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

###############################################################################
#                           Linear Algebra Functions                          #
###############################################################################

"""
    getEigenvaluesMatrix(mat::Ptr{RRDoubleMatrix})
Compute the eigenvalues of a double matrix.
"""
function getEigenvaluesMatrix(matrix::Ptr{RRDoubleMatrix})
  matrix = ccall(dlsym(rrlib, :getEigenvaluesMatrix), cdecl, Ptr{RRComplexVector}, (Ptr{RRDoubleMatrix},), matrix)
  num_row = getMatrixNumRows(matrix)
  num_col = getMatrixNumCols(matrix)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getComplexMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  end
  return data_arr
end

"""
    getEigenvaluesVector(mat::Ptr{RRDoubleMatrix})
Compute the eigenvalues of a double matrix.
"""
function getEigenvaluesVector(matrix::Ptr{RRDoubleMatrix})
  data = ccall(dlsym(rrlib, :getEigenvaluesVector), cdecl, Ptr{RRComplexVector}, (Ptr{RRDoubleMatrix},), matrix)
  num_row = getMatrixNumRows(matrix)
  num_col = getMatrixNumCols(matrix)
  data_arr = Array{Float64}(undef, num_row, num_col)
  try
    for r = 1:num_row
        for c = 1:num_col
            data_arr[r, c] = getComplexMatrixElement(data, r - 1, c - 1)
        end
    end
  catch e
    throw(e)
  end
  return data_arr
end

###############################################################################
#                               Reset Methods                                 #
###############################################################################

"""
    resetRR(rr::Ptr{Nothing})
Reset all variables of the model to their current initial values. Does not change the parameters.
"""
function reset(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :reset), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

"""
    resetAll(rr::Ptr{Nothing})
Reset all variables of the model to their current initial values, and resets all parameters to their original values.
"""
function resetAll(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :resetAll), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

"""
    resetToOriginRR(rr::Ptr{Nothing})
Reset the model to the state in which it was first loaded, including initial conditions, variables, and parameters.
"""
function resetToOrigin(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :resetToOrigin), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                          Solver Options and APIs                            #
###############################################################################
"""
    getNumRegisteredIntegrators()
Get the number of registered integrators.
"""
function getNumRegisteredIntegrators()
  return ccall(dlsym(rrlib, :getNumRegisteredIntegrators), cdecl, Cint, ())
end

"""
    getRegisteredIntegratorName(n::Int64)
Get the name of a registered integrator (e.g. cvode etc.)
"""
function getRegisteredIntegratorName(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredIntegratorName), cdecl, Ptr{UInt8}, (Cint,), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getRegisteredIntegratorHint(n::Int64)
Get the hint of a registered integrator (e.g. cvode etc.)
"""
function getRegisteredIntegratorHint(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredIntegratorHint), cdecl, Ptr{UInt8}, (Cint,), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getRegisteredIntegratorDescription(n::Int64)
Get the description of a registered integrator (e.g. cvode etc.).
"""
function getRegisteredIntegratorDescription(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredIntegratorDescription), cdecl, Ptr{UInt8}, (Cint,), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getNumInstantiatedIntegrators(rr::Ptr{Nothing})
Get the number of instantiated integrators. To instantiate an integrator, use setCurrentIntegrator.
"""
function getNumInstantiatedIntegrators(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumInstantiatedIntegrators), cdecl, Cint, (Ptr{Nothing},), rr)
end

"""
    setCurrentIntegrator(rr::Ptr{Nothing}, nameOfIntegrator::String)
Specify the current integrator to be used for simulation. This method instantiates a new integrator of the given type (e.g. cvode, gillespie) if one does not currently exist.
Otherwise, the existing integrator of this type is used.
"""
function setCurrentIntegrator(rr::Ptr{Nothing}, nameOfIntegrator::String)
  result = ccall(dlsym(rrlib, :setCurrentIntegrator), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, nameOfIntegrator)
  if result == 0
    error(getLastError())
  end
end

"""
    getCurrentIntegratorName(rr::Ptr{Nothing})
Obtain a description of the current integrator.
"""
function getCurrentIntegratorName(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorName), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorDescription(rr::Ptr{Nothing})
Obtain a description of the current integrator.
"""
function getCurrentIntegratorDescription(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    ggetCurrentIntegratorHint(rr::Ptr{Nothing})
Obtain a short hint for the current integrator.
"""
function getCurrentIntegratorHint(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorHint), cdecl, Ptr{UInt8}, (Ptr{Nothing},), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getNumberOfCurrentIntegratorParameters(rr::Ptr{Nothing})
Get the number of adjustable settings for the current integrator.
"""
function getNumberOfCurrentIntegratorParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfCurrentIntegratorParameters), cdecl, Cint, (Ptr{Nothing}, ), rr)
end

"""
    getCurrentIntegratorNthParameterName(rr::Ptr{Nothing}, n::Int64)
Get the name of a parameter of the current integrator.
"""
function getCurrentIntegratorNthParameterName(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
Get the description for a specific integrator setting.
"""
function getCurrentIntegratorNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
Get the display name of a parameter of the current integrator.
"""
function getCurrentIntegratorNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterDisplayName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorNthParameterHint(rr::Ptr{Nothing}, n::Int64)
Get the hint of a parameter of the current integrator.
"""
function getCurrentIntegratorNthParameterHint(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorNthParameterType(rr::Ptr{Nothing}, n::Int64)
Get the type of a parameter of the current integrator.
"""
function getCurrentIntegratorNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentIntegratorNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

"""
    resetCurrentIntegratorParameters(rr::Ptr{Nothing})
Reset the integrator parameters to their default values.
"""
function resetCurrentIntegratorParameters(rr::Ptr{Nothing})
  result = ccall(dlsym(rrlib, :resetCurrentIntegratorParameters), cdecl, Cint, (Ptr{Nothing},), rr)
  if result == 0
    error(getLastError())
  end
end

"""
    getListOfCurrentIntegratorParameterNames(rr::Ptr{Nothing})
Get the names of adjustable settings for the current integrator.
"""
function getListOfCurrentIntegratorParameterNames(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getListOfCurrentIntegratorParameterNames), cdecl, Ptr{RRStringArray}, (Ptr{Nothing},), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
end

"""
    getCurrentIntegratorParameterDescription(rr::Ptr{Nothing}, parameterName::String)
Get the names of adjustable settings for the current steady state solver.
"""
function getCurrentIntegratorParameterDescription(rr::Ptr{Nothing}, parameterName::String)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorParameterHint(rr::Ptr{Nothing}, parameterName::String)
Get the hint for a specific integrator setting.
"""
function getCurrentIntegratorParameterHint(rr::Ptr{Nothing}, parameterName::String)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentIntegratorParameterType(rr::Ptr{Nothing}, parameterName::String)
Get the return type for a specific integrator setting.
"""
function getCurrentIntegratorParameterType(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterType), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    getCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String)
Get the integer value for a specific integrator setting.
"""
function getCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the integer value for a specific integrator setting
"""
function setCurrentIntegratorParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  return ccall(dlsym(rrlib, :setCurrentIntegratorParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
end

"""
    getCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String)
Get the unsigned integer value for a specific integrator setting.
"""
function getCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterUInt), cdecl, Cuint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the unsigned integer value for a specific integrator setting.
"""
function setCurrentIntegratorParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterUInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cuint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

"""
    getCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String)
Get the double value for a specific integrator setting.
"""
function getCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterDouble), cdecl, Cdouble, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
Set the double value for a specific integrator setting.
"""
function setCurrentIntegratorParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterDouble), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

"""
    getCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String)
Get the string value for a specific integrator setting.
"""
function getCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String)
  char_pointer = ccall(dlsym(rrlib, :getCurrentIntegratorParameterString), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    setCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
Set the string value for a specific integrator setting.
"""
function setCurrentIntegratorParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterString), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

"""
    getCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
Get the boolean value for a specific integrator setting.
"""
function getCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentIntegratorParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the boolean value for a specific integrator setting.
"""
function setCurrentIntegratorParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentIntegratorParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == 0
    error(getLastError())
  end
end

"""
    getNumRegisteredSteadyStateSolvers()
Get the number of registered steady state solvers.
"""
function getNumRegisteredSteadyStateSolvers()
  return ccall(dlsym(rrlib, :getNumRegisteredSteadyStateSolvers), cdecl, Cint, ())
end

"""
    getRegisteredSteadyStateSolverName(n::Int64)
Get the name of a registered steady state solver (e.g. cvode etc.)
"""
function getRegisteredSteadyStateSolverName(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverName), cdecl, Ptr{UInt8}, (Cint, ), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getRegisteredSteadyStateSolverHint(n::Int64)
Get the hint of a registered steady state solver (e.g. cvode etc.)
"""
function getRegisteredSteadyStateSolverHint(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverHint), cdecl, Ptr{UInt8}, (Cint, ), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getRegisteredSteadyStateSolverDescription(n::Int64)
Get the description of a registered steady state solver (e.g. cvode etc.)
"""
function getRegisteredSteadyStateSolverDescription(n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRegisteredSteadyStateSolverDescription), cdecl, Ptr{UInt8}, (Cint, ), n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    setCurrentSteadyStateSolver(rr::Ptr{Nothing}, nameOfSteadyStateSolver::String)
Specify the current steady state solver to be used for simulation.
This method instantiates a new steady state solver of the given type (e.g. cvode, gillespie) if one does not currently exist. Otherwise, the existing steady state solver of this type is used.
"""
function setCurrentSteadyStateSolver(rr::Ptr{Nothing}, nameOfSteadyStateSolver::String)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolver), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, nameOfSteadyStateSolver)
  if status == 0
    error(getLastError())
  end
end

"""
    getCurrentSteadyStateSolverName(rr::Ptr{Nothing})
Obtain a description of the current steady state solver.
"""
function getCurrentSteadyStateSolverName(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverDescription(rr::Ptr{Nothing})
Obtain a description of the current steady state solver.
"""
function getCurrentSteadyStateSolverDescription(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverHint(rr::Ptr{Nothing})
Obtain a short hint for the current steady state solver.
"""
function getCurrentSteadyStateSolverHint(rr::Ptr{Nothing})
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, ), rr)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getNumberOfCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
Get the number of adjustable settings for the current steady state solver.
"""
function getNumberOfCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :getNumberOfCurrentSteadyStateSolverParameters), cdecl, Cint, (Ptr{Nothing}, ), rr)
end

"""
    getCurrentSteadyStateSolverNthParameterName(rr::Ptr{Nothing}, n::Int64)
Get the name of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverNthParameterName(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
Get the display name of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverNthParameterDisplayName(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterDisplayName), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
Get the description of a parameter of the current integrator.
"""
function getCurrentSteadyStateSolverNthParameterDescription(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverNthParameterHint(rr::Ptr{Nothing}, n::Int64)
Get the hint of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverNthParameterHint(rr::Ptr{Nothing}, n::Int64)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Cint), rr, n)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
Get the type of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

"""
    resetCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
Reset the steady state solver parameters to their default values.
"""
function resetCurrentSteadyStateSolverParameters(rr::Ptr{Nothing})
  status = ccall(dlsym(rrlib, :resetCurrentSteadyStateSolverParameters), cdecl, Bool, (Ptr{Nothing},), rr)
  if status == false
    error(getLastError())
  end
  return status
end

"""
    solverTypeToString(code::Int64)
Compute the eigenvalues of a double matrix.
"""
function solverTypeToString(code::Int64)
  char_pointer = ccall(dlsym(rrlib, :solverTypeToString), cdecl, Ptr{UInt8}, (Cint, ), code)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
Get the type of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverNthParameterType(rr::Ptr{Nothing}, n::Int64)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverNthParameterType), cdecl, Cint, (Ptr{Nothing}, Cint), rr, n)
end

"""
    getListOfCurrentSteadyStateSolverParameterNames(rr::Ptr{Nothing})
Get the names of adjustable settings for the current steady state solver.
"""
function getListOfCurrentSteadyStateSolverParameterNames(rr::Ptr{Nothing})
  data = ccall(dlsym(rrlib, :getListOfCurrentSteadyStateSolverParameterNames), cdecl, Ptr{RRStringArray}, (Ptr{Nothing}, ), rr)
  num = getNumberOfStringElements(data)
  Ids = String[]
  try
    for i = 1:num
      push!(Ids, getStringElement(data, i - 1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(data)
  end
  return Ids
end

"""
    getCurrentSteadyStateSolverParameterDescription(rr::Ptr{Nothing}, parameterName::String)
GGet the description for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterDescription(rr::Ptr{Nothing}, parameterName::String)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterDescription), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverParameterHint(rr::Ptr{Nothing}, parameterName::String)
Get the hint of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverParameterHint(rr::Ptr{Nothing}, parameterName::String)
  char_pointer = ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterHint), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getCurrentSteadyStateSolverParameterType(rr::Ptr{Nothing}, parameterName::String)
Get the type of a parameter of the current steady state solver.
"""
function getCurrentSteadyStateSolverParameterType(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterType), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    getCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String)
Get the integer value for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterInt), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the integer value for a specific steady state solver setting.
"""
function setCurrentSteadyStateSolverParameterInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterInt), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == false
    error(getLastError())
  end
end

"""
    getCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String)
Get the unsigned integer value for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterUInt), cdecl, Cuint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the unsigned integer value for a specific steady state solver setting.
"""
function setCurrentSteadyStateSolverParameterUInt(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterUInt), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cuint), rr, parameterName, value)
  if status == false
    error(getLastError())
  end
end

"""
    getCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String)
Get the double value for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterDouble), cdecl, Cdouble, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
Set the double value for a specific steady state solver setting.
"""
function setCurrentSteadyStateSolverParameterDouble(rr::Ptr{Nothing}, parameterName::String, value::Float64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterDouble), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cdouble), rr, parameterName, value)
  if status == false
    error(getLastError())
  end
end

"""
    getCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String)
Get the double value for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterString), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
Set the string value for a specific steady state solver setting.
"""
function setCurrentSteadyStateSolverParameterString(rr::Ptr{Nothing}, parameterName::String, value::String)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterString), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, parameterName, value)
  if status == false
    error(getLastError())
  end
end

"""
    getCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
Get the boolean value for a specific steady state solver setting.
"""
function getCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String)
  return ccall(dlsym(rrlib, :getCurrentSteadyStateSolverParameterBoolean), cdecl, Cint, (Ptr{Nothing}, Ptr{UInt8}), rr, parameterName)
end

"""
    setCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
Set the boolean value for a specific steady state solver setting.
"""
function setCurrentSteadyStateSolverParameterBoolean(rr::Ptr{Nothing}, parameterName::String, value::Int64)
  status = ccall(dlsym(rrlib, :setCurrentSteadyStateSolverParameterBoolean), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Cint), rr, parameterName, value)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                        Configuration Keys and Values                        #
###############################################################################
"""
    setConfigBool(key::String, value::Int64)
    Set a boolean configuration value.
"""
function setConfigBool(key::String, value::Int64)
    status = ccall(dlsym(rrlib, :setConfigBool), cdecl, Int64, (Ptr{UInt8}, Cint), key, value)
    if status == false
      error(getLastError())
    end
    return status
end

"""
    getConfigBool(key::String)
Get a boolean configuration value.
"""
function getConfigBool(key::String)
  return ccall(dlsym(rrlib, :getConfigBool), cdecl, Bool, (Ptr{UInt8},), key)
end

"""
    setConfigInt(key::String, value::Int64)
Set an integer configuration value.
"""
function setConfigInt(key::String, value::Int64)
    status = ccall(dlsym(rrlib, :setConfigInt), cdecl, Bool, (Ptr{UInt8}, Cint), key, value)
    if status == false
      error(getLastError())
    end
end

"""
    getConfigInt(key::String)
Get an integer configuration value.
"""
function getConfigInt(key::String)
  return ccall(dlsym(rrlib, :getConfigInt), cdecl, Cint, (Ptr{UInt8},), key)
end

"""
    setConfigDouble(key::String, value::Float64)
Set a double configuration value.
"""
function setConfigDouble(key::String, value::Float64)
  status = ccall(dlsym(rrlib, :setConfigDouble), cdecl, Bool, (Ptr{UInt8}, Cdouble), key, value)
  if status <= 0
    error(getLastError())
  end
end

"""
    getConfigDouble(key::String)
Get a double configuration value.
"""
function getConfigDouble(key::String)
  return ccall(dlsym(rrlib, :getConfigDouble), cdecl, Cdouble, (Ptr{UInt8},), key)
end

"""
    getListOfConfigKeys()
Get a list of all possible config keys.
"""
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

#This function is not in C API
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

#This function is not in C API
function resultsColumn(resultHandle, column::Int64)
  rows = getRRDataNumRows(resultHandle)
  results = Array{Float64}(undef,rows)
  for i = 0:rows - 1
    results[i + 1] = getRRCDataElement(resultHandle, i, column)
  end
  return results
end

"""
    addSpecies(rr::Ptr{Nothing}, sid::String, compartment::String, initialAmount::Float64, substanceUnit::String, regen::Bool)
    example: addSpecies(rr, s, "Compartment", 0.1, "", true)
Add a species to the current model.
"""
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

"""
    removeSpecies(rr::Ptr{Nothing}, sid::String, regen::Bool)
Remove a species from the current model.
"""
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

"""
    addCompartment(rr, cid::String, initVolume::Float64, regen::Bool)
Add a compartment to the current model.
"""
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

"""
    removeCompartment(rr, cid::String, regen::Bool)
Remove a compartment from the current model.
"""
function removeCompartment(rr, cid::String, regen::Bool)
  status = false
  if regen == true
    status = ccall(dlsym(rrlib, :removeCompartment), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, cid)
  else
    status = ccall(dlsym(rrlib, :removeCompartmentNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, cid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addReaction(rr::Ptr{Nothing}, rid::String, reactants::Array{String}, products::Array{String}, kineticLaw::String, regen::Bool)
Add a reaction to the current model by passing its info as parameters.
"""
function addReaction(rr::Ptr{Nothing}, rid::String, reactants::Array{String}, products::Array{String}, kineticLaw::String, regen::Bool)
  numReactants = length(reactants)
  numProducts = length(products)
  status = false
  if regen == true
    status = ccall(dlsym(rrlib, :addReaction), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Ptr{UInt8}}, Cint, Ptr{Ptr{UInt8}}, Cint, Ptr{UInt8}), rr, rid, reactants, numReactants, products, numProducts, kineticLaw)
  else
    status = ccall(dlsym(rrlib, :addReactionNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{Ptr{UInt8}}, Cint, Ptr{Ptr{UInt8}}, Cint, Ptr{UInt8}), rr, rid, reactants, numReactants, products, numProducts, kineticLaw)
  end
  if status == false
    error(getLastError())
  end
end

"""
    removeReaction(rr::Ptr{Nothing}, rid::String, regen::Bool)
Remove a reaction from the current model.
"""
function removeReaction(rr::Ptr{Nothing}, rid::String, regen::Bool)
  status = false
  if regen == true
    status = ccall(dlsym(rrlib, :removeReaction), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, rid)
  else
    status = ccall(dlsym(rrlib, :removeReactionNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, rid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addParameter(rr::Ptr{Nothing}, pid::String, value::Float64, forceRegen::Bool)
Add a parameter to the current model.
"""
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

"""
    removeParameter(rr::Ptr{Nothing}, pid::String, forceRegen::Bool)
Remove a parameter from the current model.
"""
function removeParameter(rr::Ptr{Nothing}, pid::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :removeParameter), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, pid)
  else
    status = ccall(dlsym(rrlib, :removeParameterNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, pid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    setKineticLaw(rr::Ptr{Nothing}, rid::String, kineticLaw::String, forceRegen::Bool)
Set the kinetic law for an existing reaction in the current model.
"""
function setKineticLaw(rr::Ptr{Nothing}, rid::String, kineticLaw::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :setKineticLaw), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, rid, kineticLaw)
  else
     status = ccall(dlsym(rrlib, :setKineticLawNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, rid, kineticLaw)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addAssignmentRule(rr::Ptr{Nothing}, vid::String, formula::String, forceRegen::Bool)
Add an assignment rule for a variable to the current model.
"""
function addAssignmentRule(rr::Ptr{Nothing}, vid::String, formula::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addAssignmentRule), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, vid, formula)
  else
    status = ccall(dlsym(rrlib, :addAssignmentRuleNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, vid, formula)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addRateRule(rr::Ptr{Nothing}, vid::String, formula::String, forceRegen::Bool)
Add a rate rule for a variable to the current model.
"""
function addRateRule(rr::Ptr{Nothing}, vid::String, formula::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addRateRule), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, vid, formula)
  else
    status = ccall(dlsym(rrlib, :addRateRuleNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, vid, formula)
  end
  if status == false
    error(getLastError())
  end
end

"""
    removeRules(rr::Ptr{Nothing}, vid::String, forceRegen::Bool)
Remove all rules for a variable from the current model, including assignment and rate rules.
"""
function removeRules(rr::Ptr{Nothing}, vid::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :removeRules), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, vid)
  else
    status = ccall(dlsym(rrlib, :removeRulesNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, vid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addEvent(rr::Ptr{Nothing}, eid::String, useValuesFromTriggerTime::Bool, trigger::String, forceRegen::Bool)
Add an event to the current model.
"""
function addEvent(rr::Ptr{Nothing}, eid::String, useValuesFromTriggerTime::Bool, trigger::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addEvent), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool, Ptr{UInt8}), rr, eid, useValuesFromTriggerTime, trigger)
  else
    status = ccall(dlsym(rrlib, :addEventNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool, Ptr{UInt8}), rr, vid, useValuesFromTriggerTime, trigger)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addTrigger(rr::Ptr{Nothing}, eid::String, trigger::String, forceRegen::Bool)
Add trigger to an existing event in the model.
"""
function addTrigger(rr::Ptr{Nothing}, eid::String, trigger::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addTrigger), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, trigger)
  else
    status = ccall(dlsym(rrlib, :addTriggerNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, trigger)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addPriority(rr::Ptr{Nothing}, eid::String, priority::String, forceRegen::Bool)
Add priority to an existing event in the model.
"""
function addPriority(rr::Ptr{Nothing}, eid::String, priority::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addPriority), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, priority)
  else
    status = ccall(dlsym(rrlib, :addPriorityNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, priority)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addDelay(rr::Ptr{Nothing}, eid::String, delay::String, forceRegen::Bool)
Add delay to an existing event in the model.
"""
function addDelay(rr::Ptr{Nothing}, eid::String, delay::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addDelay), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, delay)
  else
    status = ccall(dlsym(rrlib, :addDelayNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, delay)
  end
  if status == false
    error(getLastError())
  end
end

"""
    addEventAssignment(rr::Ptr{Nothing}, eid::String, vid::String, formulae::String, forceRegen::Bool)
Add an event assignment to an existing event in the model.
"""
function addEventAssignment(rr::Ptr{Nothing}, eid::String, vid::String, formulae::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :addEventAssignment), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, vid, formulae)
  else
    status = ccall(dlsym(rrlib, :addEventAssignmentNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, vid, formula)
  end
  if status == false
    error(getLastError())
  end
end

"""
    removeEventAssignments(rr::Ptr{Nothing}, eid::String, vid::String, forceRegen::Bool)
Add all event assignments for a variable from an existing event in the model.
"""
function removeEventAssignments(rr::Ptr{Nothing}, eid::String, vid::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :removeEventAssignments), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, vid)
  else
    status = ccall(dlsym(rrlib, :removeEventAssignmentsNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Ptr{UInt8}), rr, eid, vid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    removeEvent(rr::Ptr{Nothing}, eid::String, forceRegen::Bool)
Remove an event from the current model.
"""
function removeEvent(rr::Ptr{Nothing}, eid::String, forceRegen::Bool)
  status = false
  if forceRegen == true
     status = ccall(dlsym(rrlib, :removeEvent), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, eid)
  else
    status = ccall(dlsym(rrlib, :removeEventNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, eid)
  end
  if status == false
    error(getLastError())
  end
end

"""
    setBoundary(rr::Ptr{Nothing}, sid::String, boundaryCondition::Bool, forceRegen::Bool)
"""
function setBoundary(rr::Ptr{Nothing}, sid::String, boundaryCondition::Bool, forceRegen::Bool)
  status = false
  if forceRegen == true
    status = ccall(dlsym(rrlib, :setBoundary), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, sid, boundaryCondition)
  else
    status = ccall(dlsym(rrlib, :setBoundaryNoRegen), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}, Bool), rr, sid, boundaryCondition)
  end
  if status == false
    error(getLastError())
  end
end

"""
    isModelLoaded(rr::Ptr{Nothing})
check if a model is loaded
"""
function isModelLoaded(rr::Ptr{Nothing})
  return ccall(dlsym(rrlib, :isModelLoaded), cdecl, Bool, (Ptr{Nothing}, ), rr)
end

"""
    getParamPromotedSBML(rr::Ptr{Nothing}, sArg::String)
Promote any local parameters to global status.
"""
function getParamPromotedSBML(rr::Ptr{Nothing}, sArg::String)
  char_pointer = ccall(dlsym(rrlib, :getParamPromotedSBML), cdecl, Ptr{UInt8}, (Ptr{Nothing}, Ptr{UInt8}), rr, sArg)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end


end # module
