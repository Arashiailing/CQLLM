/**
 * @name Violation of Function Naming Convention
 * @description Identifies Python functions that do not comply with PEP8 naming standards by beginning with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Python analysis library import

// Helper predicate that determines if a function name starts with an uppercase letter
predicate violatesNamingConvention(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // Get the first character of the function name
    not firstChar = firstChar.toLowerCase()  // Check if the character is uppercase
  )
}

// Find functions that break the naming convention rules
from Function func
where
  func.inSource() and  // Function must be in the source code
  violatesNamingConvention(func) and  // Check if the function violates the naming convention
  // Exclude reporting when multiple violations exist in the same file
  not exists(Function anotherFunc |
    anotherFunc != func and  // Ensure it's a different function
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Both functions are in the same file
    violatesNamingConvention(anotherFunc)  // The other function also violates the naming convention
  )
select func, "PEP8 requires function names to start with lowercase letters."  // Display the violation with recommended fix