/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions violating PEP8 naming conventions by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library

// Predicate to check if a function name begins with an uppercase letter
predicate startsWithUppercase(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character of function name
    not initialChar = initialChar.toLowerCase()  // Verify character is uppercase
  )
}

// Identify functions violating naming convention
from Function func
where
  func.inSource() and  // Ensure function is in source code
  startsWithUppercase(func) and  // Check naming violation
  // Skip reporting if multiple violations exist in same file
  not exists(Function otherFunc |
    otherFunc != func and  // Different function instance
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file location
    startsWithUppercase(otherFunc)  // Also violates naming convention
  )
select func, "Function names should start with lowercase letters according to PEP8."  // Report violation with fix suggestion