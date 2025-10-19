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

// Find functions that violate PEP8 naming convention
from Function violatingFunction
where
  // Ensure the function is part of the source code
  violatingFunction.inSource() and
  
  // Check if the function name starts with an uppercase letter
  violatingFunction.getName().prefix(1).toUpperCase() = violatingFunction.getName().prefix(1) and
  
  // Avoid duplicate reports: only report one violation per file
  not exists(Function otherFunction |
    // Different function in the same file that also violates naming
    otherFunction != violatingFunction and
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and
    otherFunction.getName().prefix(1).toUpperCase() = otherFunction.getName().prefix(1)
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Report violation with suggestion