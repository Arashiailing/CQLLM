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
predicate hasUppercaseInitial(Function targetFunction) {
  exists(string firstChar |
    firstChar = targetFunction.getName().prefix(1) and
    firstChar = firstChar.toUpperCase()
  )
}

// Main query to find functions with uppercase initial names
from Function targetFunction
where
  // Only consider functions defined in source code
  targetFunction.inSource() and
  // Check if the function name starts with uppercase
  hasUppercaseInitial(targetFunction) and
  // Exclude cases where multiple functions in the same file have uppercase initial names
  not exists(Function otherFunction |
    otherFunction != targetFunction and
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and
    hasUppercaseInitial(otherFunction)
  )
select targetFunction, "Function names should start with lowercase letter according to Python naming conventions."