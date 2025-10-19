/**
 * @name Misnamed function
 * @description Identifies functions with uppercase-initial names that violate Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to determine if a function name begins with an uppercase letter
predicate hasUppercaseInitial(Function functionObj) {
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract the initial character of function name
    firstChar.toUpperCase() = firstChar  // Confirm the character is uppercase
  )
}

// Query to locate functions that violate Python naming conventions
from Function functionObj
where
  // Verify the function is defined in source code
  functionObj.inSource() and
  
  // Check if function name starts with uppercase letter
  hasUppercaseInitial(functionObj) and
  
  // Filter out functions that share the same file with other uppercase-named functions
  // This reduces reporting noise by focusing on isolated violations
  not exists(Function otherFunctionObj |
    otherFunctionObj != functionObj and  // Ensure it's a different function
    otherFunctionObj.getLocation().getFile() = functionObj.getLocation().getFile() and  // Same file location
    hasUppercaseInitial(otherFunctionObj)  // Also violates naming convention
  )
select functionObj, "Function names should start in lowercase."  // Report violation with suggested fix