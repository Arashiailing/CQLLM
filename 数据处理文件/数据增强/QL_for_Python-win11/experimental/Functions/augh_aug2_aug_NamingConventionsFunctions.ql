/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, 
 *              which can reduce code readability. Reports only the first such function 
 *              per file when multiple exist.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

from Function func
where
  // Ensure function exists in source code
  func.inSource() and
  
  // Check if function name starts with uppercase letter
  exists(string initialChar |
    initialChar = func.getName().prefix(1) and
    initialChar = initialChar.toUpperCase()
  ) and
  
  // Exclude if another uppercase-starting function exists in same file
  not exists(Function anotherFunc |
    anotherFunc != func and
    anotherFunc.getLocation().getFile() = func.getLocation().getFile() and
    exists(string initialChar |
      initialChar = anotherFunc.getName().prefix(1) and
      initialChar = initialChar.toUpperCase()
    )
  )
select func, "Function names should start in lowercase."