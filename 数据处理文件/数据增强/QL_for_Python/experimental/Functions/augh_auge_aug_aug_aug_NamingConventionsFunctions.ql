/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions starting with uppercase letters,
 *              violating PEP8 naming conventions for function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library

// Identify functions violating PEP8 naming convention
from Function func
where
  // Verify function is part of source code
  func.inSource() and
  
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character
    initialChar != initialChar.toLowerCase()   // Confirm uppercase
  ) and
  
  // Ensure only first violation per file is reported
  not exists(Function earlierFunc |
    earlierFunc != func and  // Different function
    earlierFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    earlierFunc.getLocation().getStartLine() < func.getLocation().getStartLine() and  // Earlier position
    exists(string earlierInitialChar |
      earlierInitialChar = earlierFunc.getName().prefix(1) and  // Extract first character
      earlierInitialChar != earlierInitialChar.toLowerCase()     // Confirm uppercase
    )
  )
select func, "Function names should start with lowercase letters according to PEP8."  // Report violation