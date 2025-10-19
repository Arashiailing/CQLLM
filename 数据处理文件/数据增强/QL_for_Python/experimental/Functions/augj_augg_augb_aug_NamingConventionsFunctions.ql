/**
 * @name Misnamed function
 * @description Identifies functions that begin with an uppercase letter, which violates Python naming conventions and reduces code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Detect functions with uppercase initial letters that are the only such functions in their file
from Function func
where
  func.inSource() and  // Ensure function is present in source code
  exists(string startingChar |
    startingChar = func.getName().prefix(1) and  // Extract first character of function name
    not startingChar = startingChar.toLowerCase()  // Verify if first character is uppercase
  ) and
  not exists(Function anotherFunc |
    anotherFunc != func and  // Exclude current function
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Ensure same file
    exists(string otherStartingChar |
      otherStartingChar = anotherFunc.getName().prefix(1) and  // Extract first character of other function name
      not otherStartingChar = otherStartingChar.toLowerCase()  // Verify if other function also starts with uppercase
    )
  )
select func, "Function names should start in lowercase."  // Report these functions with naming convention reminder