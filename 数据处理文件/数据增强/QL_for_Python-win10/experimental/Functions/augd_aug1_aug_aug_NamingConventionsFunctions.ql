/**
 * @name Function Naming Convention Violation
 * @description Identifies Python functions that don't adhere to PEP8 naming standards, which require function names to begin with lowercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis library to enable code inspection capabilities

// Predicate that determines if a function's name begins with an uppercase character
predicate startsWithCapitalLetter(Function functionObj) {
  exists(string firstChar |
    firstChar = functionObj.getName().prefix(1) and  // Extract the first character from the function name
    not firstChar = firstChar.toLowerCase()  // Confirm that the character remains uppercase when compared to its lowercase form
  )
}

// Main query logic to detect functions violating PEP8 naming conventions
from Function violatingFunction
where
  // Ensure the function is part of the source code (not library or generated code)
  violatingFunction.inSource() and
  // Check if the function violates the naming convention
  startsWithCapitalLetter(violatingFunction) and
  // Exclude results when multiple functions in the same file have the same violation
  not exists(Function otherFunction |
    otherFunction != violatingFunction and  // Verify it's a different function
    otherFunction.getLocation().getFile() = violatingFunction.getLocation().getFile() and  // Both functions reside in the same file
    startsWithCapitalLetter(otherFunction)  // The other function also violates the naming convention
  )
select violatingFunction, "Function names should start with lowercase letters according to PEP8."  // Report the violating function with a corrective message