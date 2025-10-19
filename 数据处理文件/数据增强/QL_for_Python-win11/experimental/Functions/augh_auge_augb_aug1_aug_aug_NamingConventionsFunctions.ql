/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that violate PEP8 naming conventions by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection capabilities

// Main query to identify functions violating PEP8 naming conventions
from Function violatingFunction
where
  // Ensure function is part of the source code
  violatingFunction.inSource() and
  // Check if function name starts with an uppercase letter
  (exists(string firstChar |
    firstChar = violatingFunction.getName().prefix(1) and
    not firstChar = firstChar.toLowerCase()
  )) and
  // Exclude files with multiple violations to reduce noise
  (not exists(Function siblingFunction |
    siblingFunction != violatingFunction and
    siblingFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and
    // Verify sibling function also violates naming convention
    exists(string firstChar |
      firstChar = siblingFunction.getName().prefix(1) and
      not firstChar = firstChar.toLowerCase()
    )
  ))
select violatingFunction, "Function names should start with lowercase letters according to PEP8."