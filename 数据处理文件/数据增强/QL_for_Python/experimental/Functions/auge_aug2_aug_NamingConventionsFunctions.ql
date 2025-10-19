/**
 * @name Misnamed function
 * @description Detects functions that violate Python naming conventions by starting with an uppercase letter.
 *              Such naming can reduce code readability and maintainability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python

// Query to identify functions with improper naming convention
from Function funcToCheck
where
  // Ensure the function is defined in source code (not library code)
  funcToCheck.inSource() and
  // Check if function name begins with an uppercase letter
  exists(string initialChar |
    initialChar = funcToCheck.getName().prefix(1) and
    initialChar = initialChar.toUpperCase()
  ) and
  // Exclude cases where multiple functions in the same file share the same uppercase-starting name
  not exists(Function anotherFunc |
    anotherFunc != funcToCheck and
    anotherFunc.getLocation().getFile() = funcToCheck.getLocation().getFile() and
    exists(string initialChar |
      initialChar = anotherFunc.getName().prefix(1) and
      initialChar = initialChar.toUpperCase()
    )
  )
select funcToCheck, "Function names should start with lowercase letter according to Python naming conventions."