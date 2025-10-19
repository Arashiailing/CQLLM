/**
 * @name Misnamed function
 * @description Functions with names starting with uppercase letters reduce code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python library for analyzing Python source code

// Predicate to identify functions with uppercase-initial names
predicate hasUppercaseInitialName(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character of function name
    initialChar != initialChar.toLowerCase()   // Check if character is not lowercase
  )
}

// Query to find misnamed functions while avoiding duplicate reports
from Function func
where
  func.inSource() and                    // Ensure function is defined in source code
  hasUppercaseInitialName(func) and      // Verify function starts with uppercase letter
  not exists(Function dupFunc |          // Exclude duplicate function reports
    dupFunc != func and                  // Different function instance
    dupFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    hasUppercaseInitialName(dupFunc)     // Also has uppercase-initial name
  )
select func, "Function names should start in lowercase."  // Report finding with recommendation