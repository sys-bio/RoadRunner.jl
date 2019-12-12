###################################################################################################
##### Input #####
###################################################################################################

function loadFile(filename::String)
  status = ccall(dlsym(antlib, :loadFile), cdecl, Int64, (Ptr{UInt8},), fileName)
  if status == -1
    error(getLastError())
  end
end

function loadString(model::String)
  status = ccall(dlsym(antlib, :loadString), cdecl, Int64, (Ptr{UInt8},), model)
  if status == -1
    error(getLastError())
  end
end

function loadAntimonyFile(filename::String)
  status = ccall(dlsym(antlib, :loadAntimonyFile), cdecl, Int64, (Ptr{UInt8},), fileName)
  if status == -1
    error(getLastError())
  end
end

function loadAntimonyString(antModel::String)
  status = ccall(dlsym(antlib, :loadAntimonyString), cdecl, Int64, (Ptr{UInt8},), antModel)
  if status == -1
    error(getLastError())
  end
  return status
end

function loadSBMLFile(filename::String)
  status = ccall(dlsym(antlib, :loadSBMLFile), cdecl, Int64, (Ptr{UInt8},), filename)
  if status == -1
    error(getLastError())
  end
  return status
end

function loadSBMLString(model::String)
  status = ccall(dlsym(antlib, :loadSBMLString), cdecl, Int64, (Ptr{UInt8},), model)
  if status == -1
    error(getLastError())
  end
end

function loadSBMLStringWithLocation(model::String, location::String)
  status = ccall(dlsym(antlib, :loadSBMLStringWithLocation), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), model, location)
  if status == -1
    error(getLastError())
  end
end

## loadCellMLFile, loadCellMLString
function getNumFiles()
  return ccall(dlsym(antlib, :getNumFiles), cdecl, Int64, ())
end

## revertTo

function clearPreviousLoads()
  ccall(dlsym(antlib, :clearPreviousLoads), cdecl, Cvoid, ())
end

## add dictionary, clear dictionary

###################################################################################################
##### Output #####
###################################################################################################

function writeAntimonyFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeAntimonyFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

function getAntimonyString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getAntimonyString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

function writeSBMLFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeSBMLFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

function getSBMLString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

## writeCompSBMLFile, getCompSBMLString, writeCellMLFile, getCellMLString, printAllDataFor

###################################################################################################
##### Errors and Warnings #####
###################################################################################################
function checkModule(moduleName::String)
  status = ccall(dlsym(antlib, :checkModule), cdecl, Bool, (Ptr{UInt8},), moduleName)
  if status == false
    error(getLastError())
  end
end

function getLastError()
  return unsafe_string(ccall(dlsym(antlib, :getLastError), cdecl, Ptr{UInt8}, ()))
end

function getWarnings()
  return unsafe_string(ccall(dlsym(antlib, :getWarnings), cdecl, Ptr{UInt8}, ()))
end

function getSBMLInfoMessages(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLInfoMessages), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

function getSBMLWarnings(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLWarnings), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

###################################################################################################
##### Modules #####
###################################################################################################
function getNumModules()
  return ccall(dlsym(antlib, :getNumModules), cdecl, Int64, ())
end

function getModuleNames()
  numModules = getNumModules()
  moduleNames = Array{String}(undef, numModules)

  for i = 1:numModules
    moduleNames[i] = unsafe_string(unsafe_load(ccall(dlsym(antlib, :getModuleNames), cdecl, Ptr{Ptr{UInt8}}, ()), i))
  end
  return moduleNames
end

function getNthModuleName(n::Int64)
  return unsafe_string(ccall(dlsym(antlib, :getNthModuleName), cdecl, Ptr{UInt8}, (Int64,), n))
end

function getMainModuleName()
  return unsafe_string(ccall(dlsym(antlib, :getMainModuleName), cdecl, Ptr{UInt8}, ()))
end

###################################################################################################
##### Module Interface #####
###################################################################################################

###################################################################################################
##### Replacements #####
###################################################################################################

###################################################################################################
##### Symbols and symbol information #####
###################################################################################################

###################################################################################################
##### Reaction #####
###################################################################################################

###################################################################################################
##### Interactions #####
###################################################################################################

###################################################################################################
##### Stoichiometry matrix information #####
###################################################################################################

###################################################################################################
##### Events #####
###################################################################################################

###################################################################################################
##### DNA strands #####
###################################################################################################

###################################################################################################
##### Memory management #####
###################################################################################################
function freeAll()
  ccall(dlsym(antlib, :freeAll), cdecl, Cvoid, ())
end

###################################################################################################
##### Defaults #####
###################################################################################################
