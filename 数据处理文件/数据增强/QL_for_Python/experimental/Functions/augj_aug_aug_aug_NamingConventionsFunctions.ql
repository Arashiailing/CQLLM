/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters,
 *              which contradicts the PEP8 naming conventions for function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Find functions that violate PEP8 naming convention
from Function targetFunction
where
  // Verify the function is part of the source code
  targetFunction.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = targetFunction.getName().prefix(1) and  // Extract the first character
    firstChar != firstChar.toLowerCase()                // Confirm it's uppercase
  ) and
  
  // Ensure only the first violation per file is reported to avoid duplicates
  not exists(Function anotherFunction |
    anotherFunction != targetFunction and  // Must be a different function
    anotherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file
    exists(string anotherFirstChar |
      anotherFirstChar = anotherFunction.getName().prefix(1) and  // Extract the first character
      anotherFirstChar != anotherFirstChar.toLowerCase()          // Confirm it's uppercase
    )
  )
select targetFunction, "Function names should start with lowercase letters according to PEP8."  // Report the violation with remediation advice