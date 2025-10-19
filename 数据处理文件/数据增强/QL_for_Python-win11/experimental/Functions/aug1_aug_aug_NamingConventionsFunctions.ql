/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that violate PEP8 naming conventions by starting with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Python library import for code analysis capabilities

// Helper predicate to check if a function's name starts with an uppercase letter
predicate startsWithCapitalLetter(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and  // Get the first character of the function name
    not initialChar = initialChar.toLowerCase()  // Verify the character is uppercase
  )
}

// Main query to identify functions that don't follow the naming convention
from Function targetFunc
where
  targetFunc.inSource() and  // Ensure the function is part of the source code
  startsWithCapitalLetter(targetFunc) and  // Check if the function name begins with an uppercase letter
  // Filter out results when multiple functions in the same file have the same violation
  not exists(Function similarFunc |
    similarFunc != targetFunc and  // Ensure it's not the same function
    similarFunc.getLocation().getFile() = targetFunc.getLocation().getFile() and  // Both functions are in the same file
    startsWithCapitalLetter(similarFunc)  // The other function also violates the naming convention
  )
select targetFunc, "Function names should start with lowercase letters according to PEP8."  // Output the violating function with a corrective message