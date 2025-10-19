/**
 * @name Misnamed function
 * @description Identifies functions that start with an uppercase letter, 
 *              which violates Python naming conventions and reduces code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

from Function funcToInspect
where
  // Ensure the function is defined in source code
  funcToInspect.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = funcToInspect.getName().prefix(1) and
    not firstChar = firstChar.toLowerCase()
  ) and
  
  // Exclude cases where there are multiple functions with the same name
  // in the same file that also start with uppercase
  not exists(Function anotherFunc |
    anotherFunc != funcToInspect and
    anotherFunc.getLocation().getFile() = funcToInspect.getLocation().getFile() and
    exists(string firstChar |
      firstChar = anotherFunc.getName().prefix(1) and
      not firstChar = firstChar.toLowerCase()
    )
  )
select funcToInspect, "Function names should start in lowercase."