/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that violate PEP8 naming conventions by beginning with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Query to identify functions with naming convention violations
from Function func
where
  // Ensure the function is part of the source code
  func.inSource() and
  // Check if the function name starts with an uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract the first character
    not initialChar = initialChar.toLowerCase()  // Verify it's uppercase
  ) and
  // Filter out duplicate reports from the same file
  not exists(Function otherFunc |
    otherFunc != func and  // Ensure it's a different function
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    // Verify the other function also has the same naming violation
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toLowerCase()
    )
  )
// Report the violating function with appropriate message
select func, "Function names should start with lowercase letters according to PEP8."