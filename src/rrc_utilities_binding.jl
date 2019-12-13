include("rrc_types.jl")

function getFileContent(fName::String)
  char_pointer = ccall(dlsym(rrlib, :getFileContent), cdecl, Ptr{UInt8}, (Ptr{UInt8},), fName)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function createText(text::String)
  char_pointer = ccall(dlsym(rrlib, :createText), cdecl, Ptr{UInt8}, (Ptr{UInt8},), text)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function createTextMemory(count::Int64)
  char_pointer = ccall(dlsym(rrlib, :createTextMemory), cdecl, Ptr{UInt8}, (Int64,), count)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

###############################################################################
#                            List Handling Routines                           #
###############################################################################

function createRRList()
  return ccall(dlsym(rrlib, :createRRList), cdecl, Ptr{RRList}, ())
end

function freeRRList(theList)
  ccall(dlsym(rrlib, :freeRRList), cdecl, Nothing, (Ptr{RRList},), theList)
end

function getListLength(myList)
  return ccall(dlsym(rrlib, :getListLength), cdecl, Int64, (Ptr{RRList},), myList)
end

function createIntegerItem(value::Int64)
  return ccall(dlsym(rrlib, :createIntegerItem), cdecl, Ptr{RRListItem}, (Int64,), value)
end

function createDoubleItem(value::Float64)
  return ccall(dlsym(rrlib, :createDoubleItem), cdecl, Ptr{RRListItem}, (Float64,), value)
end

function createStringItem(value::String)
  return ccall(dlsym(rrlib, :createStringItem), cdecl, Ptr{RRListItem}, (Ptr{UInt8},), value)
end

function createListItem(value::Ptr{RRList})
  return ccall(dlsym(rrlib, :createListItem), cdecl, Ptr{RRListItem}, (Ptr{RRList},), value)
end

function addItem(list::Ptr{RRList}, item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :addItem), cdecl, Int64, (Ptr{RRList}, Ptr{RRListItem}), list, item)
end

function getListItem(list::Ptr{RRList}, index::Int64)
  return ccall(dlsym(rrlib, :getListItem), cdecl, Ptr{RRListItem}, (Ptr{RRList}, Int64), list, index)
end

function isListItemInteger(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemInteger ), cdecl, Bool, (Ptr{RRListItem},), item)
end

function isListItemDouble(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemDouble ), cdecl, Bool, (Ptr{RRListItem},), item)
end

function isListItemString(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemString), cdecl, Bool, (Ptr{RRListItem},), item)
end

function isListItemList(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemList), cdecl, Bool, (Ptr{RRListItem},), item)
end

function isListItem(item::Ptr{RRListItem}, itemType)
  return ccall(dlsym(rrlib, :isListItem), cdecl, Bool, (Ptr{RRListItem}, Ptr{Nothing}), item, itemType)
end

function getIntegerListItem(item::Ptr{RRListItem})
  value = Array{Int64}(undef,1)
  status = ccall(dlsym(rrlib, :getIntegerListItem), cdecl, Bool, (Ptr{RRListItem}, Ptr{Int64}), item, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getDoubleListItem(item::Ptr{RRListItem})
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getDoubleListItem ), cdecl, Bool, (Ptr{RRListItem}, Ptr{Float64}), item, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getStringListItem(item::Ptr{RRListItem})
  return bytestring(ccall(dlsym(rrlib, :getStringListItem), cdecl, Ptr{UInt8}, (Ptr{RRListItem},), item))
end

function getList(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :getList), cdecl, Ptr{RRList}, (Ptr{RRListItem},), item)
end

###############################################################################
#                              Helper Routines                                #
###############################################################################

function getVectorLength(vector::Ptr{RRVector})
  return ccall(dlsym(rrlib, :getVectorLength), cdecl, Int64, (Ptr{RRVector},), vector)
end

function createVector(size::Int64)
  return ccall(dlsym(rrlib, :createVector), cdecl, Ptr{RRVector}, (Int64,), size)
end

function getVectorElement(vector::Ptr{RRVector}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getVectorElement), cdecl, Bool, (Ptr{RRVector}, Int64, Ptr{Float64}), vector, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function setVectorElement(vector::Ptr{RRVector}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setVectorElement), cdecl, Bool, (Ptr{RRVector}, Int64, Float64), vector, index, value)
  if status == false
    error(getLastError())
  end
end

function createRRMatrix(r::Int64, c::Int64)
  return ccall(dlsym(rrlib, :createRRMatrix), cdecl, Ptr{RRDoubleMatrix}, (Int64, Int64), r, c)
end

function getMatrixNumRows(m::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getMatrixNumRows), cdecl, Int64, (Ptr{RRDoubleMatrix},), m)
end

function getMatrixNumCols(m::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getMatrixNumCols), cdecl, Int64, (Ptr{RRDoubleMatrix},), m)
end

function getMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getMatrixElement), cdecl, Bool, (Ptr{RRDoubleMatrix}, Int64, Int64, Ptr{Cdouble}), m, r, c, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function setMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setMatrixElement), cdecl, Bool, (Ptr{RRDoubleMatrix}, Int64, Int64, Float64), m, r, c, value)
  if status == false
    error(getLastError())
  end
end

function getComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64)
  value = Ptr{RRComplex}
  status = ccall(dlsym(rrlib, :getComplexMatrixElement), cdecl, Bool, (Ptr{RRComplexMatrix}, Int64, Int64, Ptr{RRComplex}), m, r, c, value)
  if status == false
    error(getLastError())
  end
  return value
end

function setComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setComplexMatrixElement), cdecl, Bool, (Ptr{RRComplexMatrix}, Int64, Int64, Ptr{RRComplex}), m, r, c, value)
  if status == false
    error(getLastError())
  end
end

function getRRDataNumRows(rrData::Ptr{RRCData})
  return ccall(dlsym(rrlib, :getRRDataNumRows), cdecl, Int64, (Ptr{RRCData},), rrData)
end

function getRRDataNumCols(rrData::Ptr{RRCData})
  return ccall(dlsym(rrlib, :getRRDataNumCols), cdecl, Int64, (Ptr{RRCData},), rrData)
end

function getRRCDataElement(rrData::Ptr{RRCData}, r::Int64, c::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getRRCDataElement), cdecl, Bool, (Ptr{RRCData}, Int64, Int64, Ptr{Float64}), rrData, r, c, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

function getRRDataColumnLabel(rrData::Ptr{RRCData}, column::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRRDataColumnLabel), cdecl, Ptr{UInt8}, (Ptr{RRCData}, Int64), rrData, column)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function writeRRData(rr::Ptr{Nothing}, fileNameAndPath::String)
  status = ccall(dlsym(rrlib, :writeRRData), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileNameAndPath)
  if status == false
    error(getLastError())
  end
end

function compileSource(rr::Ptr{Nothing}, fName::String)
  status = ccall(dlsym(rrlib, :compileSource), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fName)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                            ToString Routines                                #
###############################################################################
function vectorToString(vecHandle::Ptr{RRVector})
   char_pointer = ccall(dlsym(rrlib, :vectorToString), cdecl, Ptr{UInt8}, (Ptr{RRVector},), vecHandle)
   julia_str = unsafe_string(char_pointer)
   freeText(char_pointer)
   return julia_str
end

function complexVectorToString(vecHandle::Ptr{RRComplexVector})
  char_pointer = ccall(dlsym(rrlib, :complexVectorToString), cdecl, Ptr{UInt8}, (Ptr{RRComplexVector},), vecHandle)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function rrCDataToString(rrData::Ptr{RRCData})
  char_pointer = ccall(dlsym(rrlib, :rrCDataToString), cdecl, Ptr{UInt8}, (Ptr{RRCData},), rrData)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function matrixToString(matrixHandle::Ptr{RRDoubleMatrix})
  char_pointer = ccall(dlsym(rrlib, :matrixToString), cdecl, Ptr{UInt8}, (Ptr{RRDoubleMatrix},), matrixHandle)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function complexMatrixToString(matrixHandle::Ptr{RRComplexMatrix})
  char_pointer = ccall(dlsym(rrlib, :complexMatrixToString), cdecl, Ptr{UInt8}, (Ptr{RRComplexMatrix},), matrixHandle)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function stringArrayToString(list::Ptr{RRStringArray})
  char_pointer = ccall(dlsym(rrlib, :stringArrayToString), cdecl, Ptr{UInt8}, (Ptr{RRStringArray},), list)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

function listToString(list::Ptr{RRList})
   char_pointer = ccall(dlsym(rrlib, :listToString), cdecl, Ptr{UInt8}, (Ptr{RRList},), list)
   julia_str = unsafe_string(char_pointer)
   freeText(char_pointer)
   return julia_str
end

###############################################################################
#                          StringArray Routines                               #
###############################################################################
function getNumberOfStringElements(list::Ptr{RRStringArray})
  return ccall(dlsym(rrlib, :getNumberOfStringElements), cdecl, Int64, (Ptr{RRStringArray},), list)
end

function getStringElement(list::Ptr{RRStringArray}, index::Int64)
  char_pointer = ccall(dlsym(rrlib, :getStringElement), cdecl, Ptr{UInt8}, (Ptr{RRStringArray}, Int64), list, index)
  julia_str = unsafe_string(char_pointer)
  freeText(char_pointer)
  return julia_str
end

###############################################################################
#                          Free Memory Routines                               #
###############################################################################
function freeRRCData(handle::Ptr{RRCData})
  status = ccall(dlsym(rrlib, :freeRRCData), cdecl, Bool, (Ptr{RRCData},), handle)
  if status == false
    (error(getLastError()))
  end
end

function freeText(text::Ptr{UInt8})
  status = ccall(dlsym(rrlib, :freeText), cdecl, Bool, (Ptr{UInt8},), text)
  if status == false
    (error(getLastError()))
  end
end

function freeStringArray(sl::Ptr{RRStringArray})
  status =  ccall(dlsym(rrlib, :freeStringArray), cdecl, Bool, (Ptr{RRStringArray},), sl)
  if status == false
    (error(getLastError()))
  end
end

function freeVector(vector::Ptr{RRVector})
  status = ccall(dlsym(rrlib, :freeVector), cdecl, Bool, (Ptr{RRVector},), vector)
  if status == false
    (error(getLastError()))
  end
end

function freeMatrix(matrix::Ptr{RRDoubleMatrix})
  status = ccall(dlsym(rrlib, :freeMatrix), cdecl, Bool, (Ptr{RRDoubleMatrix},), matrix)
  if status == false
    (error(getLastError()))
  end
end

function convertStringArrayToJuliaArray(list::Ptr{RRStringArray})
  julia_arr = String[]
  try
    num_elem = getNumberOfStringElements(list)
    for i = 1:num_elem
      push!(julia_arr, getStringElement(list, i -1))
    end
  catch e
    throw(e)
  finally
    freeStringArray(list)
  end
  return julia_arr
end

function convertRRVectorToJuliaArray(vector::Ptr{RRVector})
  julia_arr = Float64[]

  try
    num_elem = getVectorLength(vector)
    for i = 1:num_elem
      push!(julia_arr, getVectorElement(vector, i-1))
    end
  catch e
    throw(e)
  finally
    freeVector(vector)
  end
  return julia_arr
end
