/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, which violates Python naming conventions.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @tags naming-convention
 */

import python

// Predicate to determine if a function name begins with an uppercase letter
predicate startsWithUppercase(Function func) {
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    initialChar.toUpperCase() = initialChar
  )
}

// Main query to find functions with uppercase initial names
from Function func
where
  // Only consider functions defined in source code
  func.inSource() and
  // Check if the function name starts with uppercase
  startsWithUppercase(func) and
  // Exclude cases where multiple functions in the same file have uppercase initial names
  not exists(Function anotherFunc |
    anotherFunc != func and
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and
    startsWithUppercase(anotherFunc)
  )
select func, "Function names should start with lowercase letter according to Python naming conventions."