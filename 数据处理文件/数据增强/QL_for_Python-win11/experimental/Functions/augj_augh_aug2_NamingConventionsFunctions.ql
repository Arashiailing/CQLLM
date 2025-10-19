/**
 * @name Misnamed function
 * @description Identifies functions that begin with uppercase letters, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Select functions that violate Python naming conventions
from Function functionObj
where
  // Verify the function is defined in source code
  functionObj.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Get the first character of the function name
    firstChar != firstChar.toLowerCase()            // Determine if it's uppercase
  ) and
  
  // Prevent duplicate reporting for functions with the same name in the same file
  not exists(Function duplicateFunc |
    duplicateFunc != functionObj and  // Ensure it's a different function object
    duplicateFunc.getLocation().getFile() = functionObj.getLocation().getFile() and  // Check if in the same file
    exists(string duplicateFirstChar |
      duplicateFirstChar = duplicateFunc.getName().prefix(1) and
      duplicateFirstChar != duplicateFirstChar.toLowerCase()  // Verify same naming violation
    )
  )
select functionObj, "Function names should start in lowercase."  // Report the naming convention violation