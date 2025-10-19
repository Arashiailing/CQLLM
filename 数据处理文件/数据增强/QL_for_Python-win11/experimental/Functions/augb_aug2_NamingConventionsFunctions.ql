/**
 * @name Misnamed function
 * @description Identifies functions with uppercase-initial names that violate Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to detect functions starting with uppercase letters
predicate hasUppercaseInitial(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character of function name
    initialChar != initialChar.toLowerCase()  // Verify character is uppercase
  )
}

// Query to identify misnamed functions
from Function func
where
  func.inSource() and  // Ensure function is defined in source code
  hasUppercaseInitial(func) and  // Check for uppercase-initial naming
  not exists(Function otherFunc |
    otherFunc != func and  // Exclude other functions with same name
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Within same file
    hasUppercaseInitial(otherFunc)  // Also has uppercase-initial naming
  )
select func, "Function names should start in lowercase."  // Report violation with recommendation