/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that begin with uppercase letters,
 *              which violates PEP8 naming conventions for function names.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import the Python library for code analysis

// Identify functions with uppercase starting characters
from Function targetFunction
where
  // Ensure the function is part of the source code
  targetFunction.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = targetFunction.getName().prefix(1) and  // Extract the first character
    firstChar != firstChar.toLowerCase()                // Verify it's uppercase
  ) and
  
  // Prevent duplicate reports per file: only report the first violation in each file
  not exists(Function otherFunction |
    otherFunction != targetFunction and  // Ensure it's a different function
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and  // Same file
    exists(string otherFirstChar |
      otherFirstChar = otherFunction.getName().prefix(1) and  // Extract the first character
      otherFirstChar != otherFirstChar.toLowerCase()          // Verify it's uppercase
    )
  )
select targetFunction, "Function names should start with lowercase letters according to PEP8."  // Report violation with suggestion