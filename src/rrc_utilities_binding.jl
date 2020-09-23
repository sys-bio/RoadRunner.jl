include("rrc_types.jl")

@enum ListItemType litString litInteger litDouble litList

"""
    getFileContent(fName::String)
Retrieves the the content of a file.
"""
function getFileContent(fName::String)
  char_pointer = ccall(dlsym(rrlib, :getFileContent), cdecl, Ptr{UInt8}, (Ptr{UInt8},), fName)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    createText(text::String)
Creates memory for holding a string.
"""
function createText(text::String)
  char_pointer = ccall(dlsym(rrlib, :createText), cdecl, Ptr{UInt8}, (Ptr{UInt8},), text)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    createTextMemory(count::Int64)
Creates memory for holding a string.
"""
function createTextMemory(count::Int64)
  char_pointer = ccall(dlsym(rrlib, :createTextMemory), cdecl, Ptr{UInt8}, (Int64,), count)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

###############################################################################
#                            List Handling Routines                           #
###############################################################################
"""
    createRRList()
Create a new list. A list is a container for storing list items. List items can represent integers, double, strings and lists. To populate a list, create list items of the appropriate type and add them to the list
Example, build the list [123, [3.1415926]]
    1 l = createRRList(RRHandle handle);
    2 item = createIntegerItem (123);
    3 addItem (l, item);
    4 item1 = createListItem(RRHandle handle);
    5 item2 = createDoubleItem (3.1415926);
    6 addItem (item1, item2);
    7 addItem (l, item1);
    8
    9 item = getListItem (l, 0);
   10 printf ("item = %d\n", item->data.iValue);
   11
   12 printf (listToString (l));
   13 freeRRList (l);
"""
function createRRList()
  return ccall(dlsym(rrlib, :createRRList), cdecl, Ptr{RRList}, ())
end

#function createRRList()
#  list = ccall(dlsym(rrlib, :createRRList), cdecl, Ptr{RRList}, ())
#  result = listToString(list)
#  freeRRList(list)
#  return result
#end

"""
    freeRRList(theList)
Free RRListPtr structure, i.e destroy a list.
"""
function freeRRList(theList)
  ccall(dlsym(rrlib, :freeRRList), cdecl, Cvoid, (Ptr{RRList},), theList)
end

"""
    getListLength(myList)
Returns the length of a given list.
"""
function getListLength(myList)
  return ccall(dlsym(rrlib, :getListLength), cdecl, Int64, (Ptr{RRList},), myList)
end

"""
    createIntegerItem(value::Int64)
Create a list item to store an integer.
"""
function createIntegerItem(value::Int64)
  return ccall(dlsym(rrlib, :createIntegerItem), cdecl, Ptr{RRListItem}, (Int64,), value)
end

"""
    createDoubleItem(value::Float64)
Create a list item to store a double value
"""
function createDoubleItem(value::Float64)
  return ccall(dlsym(rrlib, :createDoubleItem), cdecl, Ptr{RRListItem}, (Float64,), value)
end

"""
    createStringItem(value::String)
Create a list item to store a pointer to a string.
"""
function createStringItem(value::String)
  return ccall(dlsym(rrlib, :createStringItem), cdecl, Ptr{RRListItem}, (Ptr{UInt8},), value)
end

"""
    createListItem(value::Ptr{RRList})
Create a list item to store a list.
"""
function createListItem(value::Ptr{RRList})
  return ccall(dlsym(rrlib, :createListItem), cdecl, Ptr{RRListItem}, (Ptr{RRList},), value)
end

"""
    addItem(list::Ptr{RRList}, item::Ptr{RRListItem})
Create a list item to store a double value
"""
function addItem(list::Ptr{RRList}, item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :addItem), cdecl, Int64, (Ptr{RRList}, Ptr{RRListItem}), list, item)
end

"""
    getListItem(list::Ptr{RRList}, index::Int64)
Return the index^th item from the list.
"""
function getListItem(list::Ptr{RRList}, index::Int64)
  return ccall(dlsym(rrlib, :getListItem), cdecl, Ptr{RRListItem}, (Ptr{RRList}, Int64), list, index)
end

"""
    isListItemInteger(item::Ptr{RRListItem})
Return true or false if the list item is an integer.
"""
function isListItemInteger(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemInteger ), cdecl, Bool, (Ptr{RRListItem},), item)
end

"""
    isListItemDouble(item::Ptr{RRListItem})
Return true or false if the list item is a double.
"""
function isListItemDouble(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemDouble), cdecl, Bool, (Ptr{RRListItem},), item)
end

"""
    isListItemString(item::Ptr{RRListItem})
Return true or false if the list item is a character array.
"""
function isListItemString(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemString), cdecl, Bool, (Ptr{RRListItem},), item)
end

"""
    isListItemList(item::Ptr{RRListItem})
Return true or false if the list item is a list itself.
"""
function isListItemList(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :isListItemList), cdecl, Bool, (Ptr{RRListItem},), item)
end

"""
    isListItem(item::Ptr{RRListItem}, itemType)
Returns true or false if the list item is the given itemType.
"""
function isListItem(item::Ptr{RRListItem}, itemType)
  return ccall(dlsym(rrlib, :isListItem), cdecl, Bool, (Ptr{RRListItem}, ListItemType), item, itemType)
end

"""
    getIntegerListItem(item::Ptr{RRListItem})
Return the integer from a list item.
"""
function getIntegerListItem(item::Ptr{RRListItem})
  value = Array{Int64}(undef,1)
  status = ccall(dlsym(rrlib, :getIntegerListItem), cdecl, Bool, (Ptr{RRListItem}, Ptr{Int64}), item, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getDoubleListItem(item::Ptr{RRListItem})
Return the double from a list item.
"""
function getDoubleListItem(item::Ptr{RRListItem})
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getDoubleListItem), cdecl, Bool, (Ptr{RRListItem}, Ptr{Float64}), item, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getStringListItem(item::Ptr{RRListItem})
Return the string from a list item.
"""
function getStringListItem(item::Ptr{RRListItem})
  char_pointer = ccall(dlsym(rrlib, :getStringListItem), cdecl, Ptr{UInt8}, (Ptr{RRListItem},), item)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    getList(item::Ptr{RRListItem})
Return a list from a list item if it contains a list.
"""
function getList(item::Ptr{RRListItem})
  return ccall(dlsym(rrlib, :getList), cdecl, Ptr{RRList}, (Ptr{RRListItem},), item)
end
###############################################################################
#                              Helper Routines                                #
###############################################################################
"""
    getVectorLength(vector::Ptr{RRVector})
Get the number of elements in a vector type.
"""
function getVectorLength(vector::Ptr{RRVector})
  return ccall(dlsym(rrlib, :getVectorLength), cdecl, Int64, (Ptr{RRVector},), vector)
end

"""
    createVector(size::Int64)
Create a new vector with a given size.
"""
function createVector(size::Int64)
  return ccall(dlsym(rrlib, :createVector), cdecl, Ptr{RRVector}, (Int64,), size)
end

"""
    getVectorElement(vector::Ptr{RRVector}, index::Int64)
Get a particular element from a vector.
"""
function getVectorElement(vector::Ptr{RRVector}, index::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getVectorElement), cdecl, Bool, (Ptr{RRVector}, Int64, Ptr{Cdouble}), vector, index, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setVectorElement(vector::Ptr{RRVector}, index::Int64, value::Float64)
Set a particular element in a vector.
"""
function setVectorElement(vector::Ptr{RRVector}, index::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setVectorElement), cdecl, Bool, (Ptr{RRVector}, Int64, Float64), vector, index, value)
  if status == false
    error(getLastError())
  end
end

"""
    createRRMatrix(r::Int64, c::Int64)
Create an empty matrix of size r by c.
"""
function createRRMatrix(r::Int64, c::Int64)
  return ccall(dlsym(rrlib, :createRRMatrix), cdecl, Ptr{RRDoubleMatrix}, (Int64, Int64), r, c)
end

"""
    getMatrixNumRows(m::Ptr{RRDoubleMatrix})
Retrieve the number of rows in the given matrix.
"""
function getMatrixNumRows(m::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getMatrixNumRows), cdecl, Int64, (Ptr{RRDoubleMatrix},), m)
end

"""
    getMatrixNumCols(m::Ptr{RRDoubleMatrix})
Retrieve the number of columns in the given matrix.
"""
function getMatrixNumCols(m::Ptr{RRDoubleMatrix})
  return ccall(dlsym(rrlib, :getMatrixNumCols), cdecl, Int64, (Ptr{RRDoubleMatrix},), m)
end

"""
    getMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64)
Retrieve an element at a given row and column from a matrix type variable.
"""
function getMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getMatrixElement), cdecl, Bool, (Ptr{RRDoubleMatrix}, Int64, Int64, Ptr{Cdouble}), m, r, c, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    setMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64, value::Float64)
Set an element at a given row and column with a given value in a matrix type variable.
"""
function setMatrixElement(m::Ptr{RRDoubleMatrix}, r::Int64, c::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setMatrixElement), cdecl, Bool, (Ptr{RRDoubleMatrix}, Int64, Int64, Float64), m, r, c, value)
  if status == false
    error(getLastError())
  end
end

"""
    getComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64)
Retrieve an element at a given row and column from a complex matrix type variable.
"""
function getComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64)
  value = Ptr{RRComplex}
  status = ccall(dlsym(rrlib, :getComplexMatrixElement), cdecl, Bool, (Ptr{RRComplexMatrix}, Int64, Int64, Ptr{RRComplex}), m, r, c, value)
  if status == false
    error(getLastError())
  end
  return value
end

"""
    setComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64, value::Float64)
Set an element at a given row and column with a given value in a complex matrix type variable.
"""
function setComplexMatrixElement(m::Ptr{RRComplexMatrix}, r::Int64, c::Int64, value::Float64)
  status = ccall(dlsym(rrlib, :setComplexMatrixElement), cdecl, Bool, (Ptr{RRComplexMatrix}, Int64, Int64, Ptr{RRComplex}), m, r, c, value)
  if status == false
    error(getLastError())
  end
end

"""
    getRRDataNumRows(rrData::Ptr{RRCData})
Retrieve the number of rows in the given RoadRunner numerical data (returned from simulate(RRHandle handle))
"""
function getRRDataNumRows(rrData::Ptr{RRCData})
  return ccall(dlsym(rrlib, :getRRDataNumRows), cdecl, Int64, (Ptr{RRCData},), rrData)
end

"""
    getRRDataNumCols(rrData::Ptr{RRCData})
Retrieve the number of columns in the given RoadRunner numerical data (returned from simulate(RRHandle handle))
"""
function getRRDataNumCols(rrData::Ptr{RRCData})
  return ccall(dlsym(rrlib, :getRRDataNumCols), cdecl, Int64, (Ptr{RRCData},), rrData)
end

"""
    function getRRCDataElement(rrData::Ptr{RRCData}, r::Int64, c::Int64)
Retrieves an element at a given row and column from a RoadRunner data type variable.
"""
function getRRCDataElement(rrData::Ptr{RRCData}, r::Int64, c::Int64)
  value = Array{Float64}(undef,1)
  status = ccall(dlsym(rrlib, :getRRCDataElement), cdecl, Bool, (Ptr{RRCData}, Int64, Int64, Ptr{Float64}), rrData, r, c, value)
  if status == false
    error(getLastError())
  end
  return value[1]
end

"""
    getRRDataColumnLabel(rrData::Ptr{RRCData}, column::Int64)
Retrieves a label for a given column in a rrData type variable.
"""
function getRRDataColumnLabel(rrData::Ptr{RRCData}, column::Int64)
  char_pointer = ccall(dlsym(rrlib, :getRRDataColumnLabel), cdecl, Ptr{UInt8}, (Ptr{RRCData}, Int64), rrData, column)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    writeRRData(rr::Ptr{Nothing}, fileNameAndPath::String)
Writes RoadRunner data to file.
"""
function writeRRData(rr::Ptr{Nothing}, fileNameAndPath::String)
  status = ccall(dlsym(rrlib, :writeRRData), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fileNameAndPath)
  if status == false
    error(getLastError())
  end
end

"""
    compileSource(rr::Ptr{Nothing}, fName::String)
Compiles source code.
"""
function compileSource(rr::Ptr{Nothing}, fName::String)
  status = ccall(dlsym(rrlib, :compileSource), cdecl, Bool, (Ptr{Nothing}, Ptr{UInt8}), rr, fName)
  if status == false
    error(getLastError())
  end
end

###############################################################################
#                            ToString Routines                                #
###############################################################################
"""
    vectorToString(vecHandle::Ptr{RRVector})
Returns a vector in string form.
"""
function vectorToString(vecHandle::Ptr{RRVector})
  char_pointer = ccall(dlsym(rrlib, :vectorToString), cdecl, Ptr{UInt8}, (Ptr{RRVector},), vecHandle)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    complexVectorToString(vecHandle::Ptr{RRComplexVector})
Returns a complex vector in string form.
"""
function complexVectorToString(vecHandle::Ptr{RRComplexVector})
  char_pointer = ccall(dlsym(rrlib, :complexVectorToString), cdecl, Ptr{UInt8}, (Ptr{RRComplexVector},), vecHandle)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    rrCDataToString(rrData::Ptr{RRCData})
Returns a rrCData struct in string form.
"""
function rrCDataToString(rrData::Ptr{RRCData})
  char_pointer = ccall(dlsym(rrlib, :rrCDataToString), cdecl, Ptr{UInt8}, (Ptr{RRCData},), rrData)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    matrixToString(matrixHandle::Ptr{RRDoubleMatrix})
Returns a matrix in string form.
"""
function matrixToString(matrixHandle::Ptr{RRDoubleMatrix})
  char_pointer = ccall(dlsym(rrlib, :matrixToString), cdecl, Ptr{UInt8}, (Ptr{RRDoubleMatrix},), matrixHandle)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    complexMatrixToString(matrixHandle::Ptr{RRComplexMatrix})
Returns a complex matrix in string form.
"""
function complexMatrixToString(matrixHandle::Ptr{RRComplexMatrix})
  char_pointer = ccall(dlsym(rrlib, :complexMatrixToString), cdecl, Ptr{UInt8}, (Ptr{RRComplexMatrix},), matrixHandle)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    stringArrayToString(list::Ptr{RRStringArray})
Returns a string list in string form.
"""
function stringArrayToString(list::Ptr{RRStringArray})
  char_pointer = ccall(dlsym(rrlib, :stringArrayToString), cdecl, Ptr{UInt8}, (Ptr{RRStringArray},), list)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

"""
    listToString(list::Ptr{RRList})
Returns a list in string form.
"""
function listToString(list::Ptr{RRList})
  char_pointer = ccall(dlsym(rrlib, :listToString), cdecl, Ptr{UInt8}, (Ptr{RRList},), list)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

###############################################################################
#                          StringArray Routines                               #
###############################################################################
"""
    getNumberOfStringElements(list::Ptr{RRStringArray})
Returns the length of a string array.
"""
function getNumberOfStringElements(list::Ptr{RRStringArray})
  return ccall(dlsym(rrlib, :getNumberOfStringElements), cdecl, Int64, (Ptr{RRStringArray},), list)
end

"""
    getStringElement(list::Ptr{RRStringArray}, index::Int64)
Returns the indexth element from the string array in the argument value.
"""
function getStringElement(list::Ptr{RRStringArray}, index::Int64)
  char_pointer = ccall(dlsym(rrlib, :getStringElement), cdecl, Ptr{UInt8}, (Ptr{RRStringArray}, Int64), list, index)
  julia_str = unsafe_string(char_pointer)
  return julia_str
end

###############################################################################
#                          Free Memory Routines                               #
###############################################################################
"""
    freeRRCData(handle::Ptr{RRCData})
Free the memory associated to a RRCData object.
"""
function freeRRCData(handle::Ptr{RRCData})
  status = ccall(dlsym(rrlib, :freeRRCData), cdecl, Bool, (Ptr{RRCData},), handle)
  if status == false
    (error(getLastError()))
  end
end

"""
    freetext(text::Ptr{UInt8})
Free char* generated by library routines.
"""
function freetext(text::Ptr{UInt8})
  status = ccall(dlsym(rrlib, :freetext), cdecl, Bool, (Ptr{UInt8},), text)
  if status == false
    (error(getLastError()))
  end
end

"""
    freeStringArray(sl::Ptr{RRStringArray})
Free RRStringListHandle structures
"""
function freeStringArray(sl::Ptr{RRStringArray})
  status =  ccall(dlsym(rrlib, :freeStringArray), cdecl, Bool, (Ptr{RRStringArray},), sl)
  if status == false
    (error(getLastError()))
  end
end

"""
    freeVector(vector::Ptr{RRVector})
Free RRVectorHandle structures.
"""
function freeVector(vector::Ptr{RRVector})
  status = ccall(dlsym(rrlib, :freeVector), cdecl, Bool, (Ptr{RRVector},), vector)
  if status == false
    (error(getLastError()))
  end
end

"""
    freeMatrix(matrix::Ptr{RRDoubleMatrix})
Free RRDoubleMatrixPtr structures.
"""
function freeMatrix(matrix::Ptr{RRDoubleMatrix})
  status = ccall(dlsym(rrlib, :freeMatrix), cdecl, Bool, (Ptr{RRDoubleMatrix},), matrix)
  if status == false
    (error(getLastError()))
  end
end

#the two functions below are not available in C API, but as Helper
"""
    convertStringArrayToJuliaArray(list::Ptr{RRStringArray})
"""
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

"""
    convertRRVectorToJuliaArray(vector::Ptr{RRVector})
"""
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
