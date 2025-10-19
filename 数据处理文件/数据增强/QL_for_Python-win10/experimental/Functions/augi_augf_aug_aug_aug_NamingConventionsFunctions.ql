/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that start with uppercase letters,
 *              violating PEP8 standards which mandate function names to begin with lowercase.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection

// Identify functions that don't follow PEP8 naming conventions
from Function misnamedFunction
where
  // Confirm the function is part of the actual source code
  misnamedFunction.inSource() and
  
  // Extract and validate the initial character of the function name
  exists(string firstChar |
    firstChar = misnamedFunction.getName().prefix(1) and  // Retrieve the first character
    firstChar != firstChar.toLowerCase()                  // Check if it's uppercase
  ) and
  
  // Limit reporting to the first violation per file to prevent duplicate alerts
  not exists(Function earlierViolation |
    earlierViolation != misnamedFunction and  // Ensure it's a different function
    earlierViolation.getLocation().getFile() = misnamedFunction.getLocation().getFile() and  // Same source file
    exists(string earlierFirstChar |
      earlierFirstChar = earlierViolation.getName().prefix(1) and  // Get the first character
      earlierFirstChar != earlierFirstChar.toLowerCase()            // Confirm uppercase violation
    )
  )
select misnamedFunction, "Function names should start with lowercase letters according to PEP8."  // Display violation with suggested fix