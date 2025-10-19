/**
 * @name Misnamed function
 * @description Detects functions that start with an uppercase letter,
 *              which contradicts Python naming conventions and reduces code clarity.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Helper predicate to identify functions with names starting with an uppercase letter
predicate hasUppercaseName(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and
    not firstChar = firstChar.toLowerCase()
  )
}

// Main query to find functions with naming convention violations
from Function func
where
  // Check if the function is part of the source code
  func.inSource() and
  
  // Verify the function name starts with an uppercase letter
  hasUppercaseName(func) and
  
  // Exclude duplicate reports for functions with the same name in the same file
  not exists(Function duplicateFunc |
    duplicateFunc != func and
    duplicateFunc.getLocation().getFile() = func.getLocation().getFile() and
    hasUppercaseName(duplicateFunc)
  )
select func, "Function names should start in lowercase."