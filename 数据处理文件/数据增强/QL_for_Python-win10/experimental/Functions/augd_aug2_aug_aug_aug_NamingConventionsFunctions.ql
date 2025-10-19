/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that start with uppercase letters,
 *              violating PEP8 naming conventions which require function names
 *              to begin with lowercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Identify functions that violate PEP8 naming conventions
from Function func
where
  // Ensure the function is part of the source code
  func.inSource() and
  
  // Check if function name starts with an uppercase letter
  (exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Get the first character
    initialChar != initialChar.toLowerCase()   // Verify it's uppercase
  )) and
  
  // Report only the first violation per file to prevent duplicates
  (not exists(Function otherFunc |
    otherFunc != func and  // Must be a different function
    otherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    exists(string otherInitialChar |
      otherInitialChar = otherFunc.getName().prefix(1) and  // Get the first character
      otherInitialChar != otherInitialChar.toLowerCase()    // Verify it's uppercase
    )
  ))
select func, "Function names should start with lowercase letters according to PEP8."  // Report the violation with a suggestion