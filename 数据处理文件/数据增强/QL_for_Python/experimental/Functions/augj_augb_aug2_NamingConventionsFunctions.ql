/**
 * @name Function with uppercase initial
 * @description Detects functions that start with an uppercase letter, which contradicts Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to detect functions starting with uppercase letters
predicate hasUppercaseInitial(Function functionObj) {
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract first character of function name
    firstChar != firstChar.toLowerCase()  // Verify character is uppercase
  )
}

// Query to identify misnamed functions
from Function functionObj
where
  functionObj.inSource() and  // Ensure function is defined in source code
  hasUppercaseInitial(functionObj) and  // Check for uppercase-initial naming
  not exists(Function otherFunction |
    otherFunction != functionObj and  // Exclude other functions with same name
    otherFunction.getLocation().getFile() = functionObj.getLocation().getFile() and  // Within same file
    hasUppercaseInitial(otherFunction)  // Also has uppercase-initial naming
  )
select functionObj, "Function names should start in lowercase."  // Report violation with recommendation