/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that start with uppercase letters,
 *              which violates the PEP8 naming conventions for functions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library

// Identify functions that don't follow PEP8 naming conventions
from Function nonCompliantFunction
where
  // Ensure the function is part of the actual source code
  nonCompliantFunction.inSource() and
  
  // Check if the function name begins with an uppercase letter
  (exists(string initialChar |
    initialChar = nonCompliantFunction.getName().prefix(1) and  // Extract the first character
    initialChar != initialChar.toLowerCase()  // Verify it's uppercase
  )) and
  
  // Limit reporting to only the first violation per file to prevent duplicate alerts
  not exists(Function otherViolation |
    otherViolation != nonCompliantFunction and  // Ensure it's a different function
    otherViolation.getLocation().getFile() = nonCompliantFunction.getLocation().getFile() and  // Same file location
    exists(string otherInitialChar |
      otherInitialChar = otherViolation.getName().prefix(1) and  // Extract first character of other function
      otherInitialChar != otherInitialChar.toLowerCase()  // Verify it's also uppercase
    )
  )
select nonCompliantFunction, "Function names should start with lowercase letters according to PEP8."  // Display violation with suggested fix