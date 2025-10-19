/**
 * @name Misnamed function
 * @description Identifies functions that start with an uppercase letter, violating Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python

// Predicate to check if a function name starts with an uppercase letter
predicate isUpperCaseFunction(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // Extract the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Verify the character is not lowercase
  )
}

// Query to find functions with improper naming convention
from Function func
where
  // Ensure the function is defined in source code
  func.inSource() and
  // Check if the function violates naming convention
  isUpperCaseFunction(func) and
  // Exclude duplicate function names in the same file
  not exists(Function otherFunc |
    otherFunc != func and
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and
    isUpperCaseFunction(otherFunc)
  )
select func, "Function names should start in lowercase."