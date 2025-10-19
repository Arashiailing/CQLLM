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

import python  // Import the Python library for code analysis

// Identify functions with uppercase starting characters
from Function func
where
  // Ensure function is in source code
  func.inSource() and
  
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Extract first character
    initialChar != initialChar.toLowerCase()    // Verify uppercase
  ) and
  
  // Prevent duplicate reports per file: only report first violation
  not exists(Function otherFunc |
    otherFunc != func and  // Ensure different function
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and  // Extract first character
      otherInitialChar != otherInitialChar.toLowerCase()    // Verify uppercase
    )
  )
select func, "Function names should start with lowercase letters according to PEP8."  // Report violation with suggestion