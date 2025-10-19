/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that violate PEP8 naming conventions by using uppercase letters at the beginning of their names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection capabilities

// Helper predicate to check if a function's name starts with an uppercase letter
predicate startsWithUppercase(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character of function name
    not initialChar = initialChar.toLowerCase()  // Verify character is uppercase
  )
}

// Main query to detect functions violating PEP8 naming conventions
from Function misnamedFunc
where
  // Ensure function is part of the source code
  misnamedFunc.inSource() and
  // Check for uppercase initial in function name
  startsWithUppercase(misnamedFunc) and
  // Exclude files with multiple violations to reduce noise
  not exists(Function peerFunc |
    // Ensure different function in same file
    peerFunc != misnamedFunc and
    peerFunc.getLocation().getFile() = misnamedFunc.getLocation().getFile() and
    // Verify peer function also violates naming convention
    startsWithUppercase(peerFunc)
  )
select misnamedFunc, "Function names should start with lowercase letters according to PEP8."