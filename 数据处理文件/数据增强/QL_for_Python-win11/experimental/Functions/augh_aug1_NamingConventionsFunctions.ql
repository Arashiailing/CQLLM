/**
 * @name Function with Uppercase Initial
 * @description Detects Python functions that begin with an uppercase letter, which is inconsistent with PEP8 naming standards.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP8 naming conventions
 */

import python  // Import Python library for code analysis

// Helper predicate to check if a function name starts with an uppercase letter
predicate startsWithUppercase(Function func) {
  // Extract first character and verify it's uppercase
  func.getName().prefix(1).toLowerCase() != func.getName().prefix(1)
}

// Query to find functions violating naming conventions
from Function funcToCheck
where
  funcToCheck.inSource() and  // Ensure function is in source code
  startsWithUppercase(funcToCheck) and  // Function starts with uppercase
  // Exclude if there are other functions in the same file that also start with uppercase
  not exists(Function otherFunc |
    otherFunc != funcToCheck and  // Exclude the function itself
    otherFunc.getLocation().getFile() = funcToCheck.getLocation().getFile() and  // Same file
    startsWithUppercase(otherFunc)  // Other function also starts with uppercase
  )
select funcToCheck, "Function names should start in lowercase."  // Report violation