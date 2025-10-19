/**
 * @name Misnamed function
 * @description Identifies functions that start with a capital letter and are the only such function in their file,
 *              which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Predicate to check if a function's name begins with a capital letter
predicate isCapitalStart(Function func) {
  // Extract the first character of the function name and verify it's uppercase
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    initialChar != initialChar.toLowerCase()
  )
}

// Identify functions violating naming conventions
from Function func
where
  // Function must be defined in source code
  func.inSource() and
  // Function name starts with capital letter
  isCapitalStart(func) and
  // No other function in the same file starts with capital letter
  not exists(Function other |
    // Exclude current function from comparison
    other != func and
    // Ensure functions are in the same file
    other.getLocation().getFile() = func.getLocation().getFile() and
    // Other function also violates naming convention
    isCapitalStart(other)
  )
select func, "Function names should start in lowercase."