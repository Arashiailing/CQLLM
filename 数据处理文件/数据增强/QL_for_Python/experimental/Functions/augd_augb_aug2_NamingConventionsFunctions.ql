/**
 * @name Misnamed function
 * @description Detects Python functions that begin with uppercase letters, violating the standard naming convention.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Helper predicate to identify functions with uppercase-initial names
predicate hasUppercaseInitial(Function fn) {
  exists(string firstChar |
    firstChar = fn.getName().prefix(1) and  // Extract the initial character of function name
    firstChar != firstChar.toLowerCase()   // Confirm the character is uppercase
  )
}

// Query to find functions that violate Python naming conventions
from Function targetFn
where
  // Ensure function is defined in source code
  targetFn.inSource() and  
  // Check for uppercase-initial naming pattern
  hasUppercaseInitial(targetFn) and  
  // Filter out files with multiple uppercase-initial functions
  not exists(Function otherFn |
    otherFn != targetFn and  // Exclude the current function
    otherFn.getLocation().getFile() = targetFn.getLocation().getFile() and  // Same file check
    hasUppercaseInitial(otherFn)  // Also has uppercase-initial naming
  )
select targetFn, "Function names should start in lowercase."  // Report violation with recommendation