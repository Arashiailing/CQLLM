/**
 * @name Function with Uppercase Initial
 * @description Detects functions that violate Python PEP8 naming conventions by starting with an uppercase letter.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP8 naming conventions
 */

import python  // Import Python library for code analysis

// Select functions that violate naming conventions
from Function violatingFunction
where
  // Ensure the function is defined in source code
  violatingFunction.inSource() and
  
  // Check if function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = violatingFunction.getName().prefix(1) and
    not firstChar = firstChar.toLowerCase()
  ) and
  
  // Exclude cases where multiple functions in the same file have uppercase initials
  not exists(Function otherFunction |
    otherFunction != violatingFunction and
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and
    exists(string otherFirstChar |
      otherFirstChar = otherFunction.getName().prefix(1) and
      not otherFirstChar = otherFirstChar.toLowerCase()
    )
  )
  
// Report the function with the violation message
select violatingFunction, "Function names should start in lowercase."