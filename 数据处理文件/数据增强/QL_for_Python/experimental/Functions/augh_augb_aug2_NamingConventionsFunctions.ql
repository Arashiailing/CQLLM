/**
 * @name Misnamed function
 * @description Detects functions that begin with uppercase letters, which contradicts Python's PEP 8 naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python  // Import Python analysis library

// Predicate that checks if a function name starts with an uppercase letter
predicate startsWithUppercase(Function func) {
  exists(string firstChar |
    firstChar = func.getName().prefix(1) and  // Get the first character of the function name
    firstChar != firstChar.toLowerCase()  // Check if the character is uppercase
  )
}

// Main query that identifies functions violating naming conventions
from Function func
where
  func.inSource() and  // Function must be defined in source code (not library)
  startsWithUppercase(func) and  // Function name starts with uppercase
  not exists(Function anotherFunc |
    anotherFunc != func and  // Exclude the current function
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and  // Same file
    startsWithUppercase(anotherFunc)  // Also starts with uppercase
  )
select func, "Function names should start with lowercase letters."  // Output the violation with a message