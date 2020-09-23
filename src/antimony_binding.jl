###################################################################################################
##### Input #####
###################################################################################################
"""
  loadFile(filename::String)
Load a file of any format libAntimony knows about (potentially Antimony, SBML, or CellML).
"""
function loadFile(filename::String)
  status = ccall(dlsym(antlib, :loadFile), cdecl, Int64, (Ptr{UInt8},), fileName)
  if status == -1
    error(getLastError())
  end
end

"""
  loadString(model::String)
Load a string of any format libAntimony knows about (potentially Antimony, SBML, or CellML).
"""
function loadString(model::String)
  status = ccall(dlsym(antlib, :loadString), cdecl, Int64, (Ptr{UInt8},), model)
  if status == -1
    error(getLastError())
  end
end

"""
  loadAntimonyFile(filename::String)
Loads a file and parses it as an Antimony file.
"""
function loadAntimonyFile(filename::String)
  status = ccall(dlsym(antlib, :loadAntimonyFile), cdecl, Int64, (Ptr{UInt8},), fileName)
  if status == -1
    error(getLastError())
  end
end

"""
  loadAntimonyString(antModel::String)
Loads a string and parses it as an Antimony set of modules.
"""
function loadAntimonyString(antModel::String)
  status = ccall(dlsym(antlib, :loadAntimonyString), cdecl, Int64, (Ptr{UInt8},), antModel)
  if status == -1
    error(getLastError())
  end
  return status
end

"""
  loadSBMLFile(filename::String)
Load a file known to be SBML.
"""
function loadSBMLFile(filename::String)
  status = ccall(dlsym(antlib, :loadSBMLFile), cdecl, Int64, (Ptr{UInt8},), filename)
  if status == -1
    error(getLastError())
  end
  return status
end

"""
  loadSBMLString(model::String)
Load a string known to be SBML.
"""
function loadSBMLString(model::String)
  status = ccall(dlsym(antlib, :loadSBMLString), cdecl, Int64, (Ptr{UInt8},), model)
  if status == -1
    error(getLastError())
  end
end

"""
  loadSBMLStringWithLocation(model::String, location::String)
Load a string known to be SBML with its file location.
"""
function loadSBMLStringWithLocation(model::String, location::String)
  status = ccall(dlsym(antlib, :loadSBMLStringWithLocation), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), model, location)
  if status == -1
    error(getLastError())
  end
end


"""
  loadCellMLFile(filename::String)
Load a file known to be CellML.
"""
function loadCellMLFile(filename::String)
  status = ccall(dlsym(antlib, :loadCellMLFile), cdecl, Int64, (Ptr{UInt8},), filename)
  if status == -1
    error(getLastError())
  end
end

"""
  loadCellMLString(model::String)
Load a string known to be CellML.
"""
function loadCellMLString(model::String)
  status = ccall(dlsym(antlib, :loadCellMLString), cdecl, Int64, (Ptr{UInt8},), model)
  if status == -1
    error(getLastError())
  end
end

"""
  getNumFiles()
Returns the number of files loaded into memory so far.
"""
function getNumFiles()
  return ccall(dlsym(antlib, :getNumFiles), cdecl, UInt64, ())
end

"""
  revertTo(Index)
Change the 'active' set of modules to the ones from the given index (as received from 'load<file/string>').
"""
function revertTo(Index)
  status = ccall(dlsym(antlib, :revertTo), cdecl, Bool, (Int64,), Index)
  if status == false
    error(getLastError())
  end
end

"""
  checkModule(moduleName::String)
Returns 'true' if the submitted module name exists in the current active set, 'false' if not.
"""
function checkModule(moduleName::String)
  status = ccall(dlsym(antlib, :checkModule), cdecl, Bool, (Ptr{UInt8},), moduleName)
  if status == false
    error(getLastError())
  end
end

"""
  clearPreviousLoads()
Clears memory of all files loaded.
"""
function clearPreviousLoads()
  ccall(dlsym(antlib, :clearPreviousLoads), cdecl, Cvoid, ())
end

"""
  addDirectory(directory::String)
Add a directory in which imported files may be found,
and in which to look for a '.antimony' file
(which contains rules about where to look locally for imported antimony and sbml files).
"""
function addDirectory(directory::String)
  status = ccall(dlsym(antlib, :addDirectory), cdecl, Int64, (Ptr{UInt8},), directory)
  if status == -1
    error(getLastError())
  end
end

"""
  clearDirectories()
Clears the list of directories added with the 'addDirectory' function.
"""
function clearDirectories()
  status = ccall(dlsym(antlib, :clearDirectories), cdecl, Int64, ())
  if status == -1
    error(getLastError())
  end
end

###################################################################################################
##### Output #####
###################################################################################################
"""
  writeAntimonyFile(filename::String, moduleName::String)
Writes out an antimony-formatted file containing the given module.
"""
function writeAntimonyFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeAntimonyFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

"""
  getAntimonyString(moduleName::String)
Returns the same output as writeAntimonyFile, but to a char* array instead of to a file.
"""
function getAntimonyString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getAntimonyString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

"""
  writeSBMLFile(filename::String, moduleName::String)
Writes out a SBML-formatted XML file to the file indicated.
"""
function writeSBMLFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeSBMLFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

"""
  getSBMLString(moduleName::String)
Returns the same output as writeSBMLFile, but to a char* array instead of to a file.
"""
function getSBMLString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

"""
  writeCompSBMLFile(filename::String, moduleName::String)
Writes out a SBML-formatted XML file to the file indicated,
using the 'Hierarchichal Model Composition' package
"""
function writeCompSBMLFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeCompSBMLFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

"""
  getCompSBMLString(moduleName::String)
Returns the same output as writeSBMLFile, but to a char* array instead of to a file,
using the 'Hierarchichal Model Composition' package.
"""
function getCompSBMLString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getCompSBMLString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

"""
  writeCellMLFile(filename::String, moduleName::String)
Writes out a CellML-formatted XML file to the file indicated,
retaining the same Antimony hierarchy using the CellML 'component' hieararchy.
"""
function writeCellMLFile(filename::String, moduleName::String)
  status = ccall(dlsym(antlib, :writeCellMLFile), cdecl, Int64, (Ptr{UInt8}, Ptr{UInt8}), filename, moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

"""
  getCellMLString(moduleName::String)
Writes out a CellML-formatted XML file to the file indicated,
retaining the same Antimony hierarchy using the CellML 'component' hieararchy.
"""
function getCellMLString(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getCellMLString), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

"""
  printAllDataFor(moduleName::String)
An example function that will print to stdout all the information in the given module.
"""
function printAllDataFor(moduleName::String)
  status = ccall(dlsym(antlib, :printAllDataFor), cdecl, Cvoid, (Ptr{UInt8},), moduleName)
  if status == 0
    error(getLastError())
  end
  return status
end

###################################################################################################
##### Errors and Warnings #####
###################################################################################################
"""
  checkModule(moduleName::String)
Returns 'true' if the submitted module name exists in the current active set, 'false' if not.
"""
function checkModule(moduleName::String)
  status = ccall(dlsym(antlib, :checkModule), cdecl, Bool, (Ptr{UInt8},), moduleName)
  if status == false
    error(getLastError())
  end
end

"""
  getLastError()
When any function returns an error condition, a longer description of the problem is
stored in memory, and is obtainable with this function.
"""
function getLastError()
  return unsafe_string(ccall(dlsym(antlib, :getLastError), cdecl, Ptr{UInt8}, ()))
end

"""
  getWarnings()
When translating some other format to Antimony, elements that are unable to be
translated are saved as warnings, retrievable with this function
(returns NULL if no warnings present).
"""
function getWarnings()
  return unsafe_string(ccall(dlsym(antlib, :getWarnings), cdecl, Ptr{UInt8}, ()))
end

"""
  getSBMLInfoMessages(moduleName::String)
Returns the 'info' messages from libSBML.
"""
function getSBMLInfoMessages(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLInfoMessages), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

"""
  getSBMLWarnings(moduleName::String)
Returns the 'warning' messages from libSBML.
"""
function getSBMLWarnings(moduleName::String)
  return unsafe_string(ccall(dlsym(antlib, :getSBMLWarnings), cdecl, Ptr{UInt8}, (Ptr{UInt8},), moduleName))
end

###################################################################################################
##### Modules #####
###################################################################################################
"""
  getNumModules()
Returns the number of modules in the current active set
(the last file successfully loaded, or whichever file was returned to with 'revertTo').
"""
function getNumModules()
  return ccall(dlsym(antlib, :getNumModules), cdecl, Int64, ())
end

"""
  getModuleNames()
Returns an array of all the current module names.
"""
function getModuleNames()
  numModules = getNumModules()
  moduleNames = Array{String}(undef, numModules)
  for i = 1:numModules
    moduleNames[i] = unsafe_string(unsafe_load(ccall(dlsym(antlib, :getModuleNames), cdecl, Ptr{Ptr{UInt8}}, (UInt64,), i)))
  end
  return moduleNames
end

"""
  getNthModuleName(n::Int64)
Returns the nth module name.
"""
function getNthModuleName(n::Int64)
  return unsafe_string(ccall(dlsym(antlib, :getNthModuleName), cdecl, Ptr{UInt8}, (Int64,), n))
end

"""
  getMainModuleName()
Returns the 'main' module name.
"""
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

"""
  freeAll()
Frees all pointers handed to you by libAntimony.
"""
function freeAll()
  ccall(dlsym(antlib, :freeAll), cdecl, Cvoid, ())
end

###################################################################################################
##### Defaults #####
###################################################################################################
