/**
 * @name Misnamed function
 * @description Detects functions that begin with an uppercase letter, 
 *              which contradicts Python naming standards and affects code clarity.
 *              The query limits reporting to a single function per file when multiple
 *              violations exist to prevent redundant alerts within the same file.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

from Function funcToCheck
where
  // Confirm the function is defined in user source code (excluding library files)
  funcToCheck.inSource() and
  
  // Validate that the function name starts with an uppercase character
  exists(string initialChar |
    initialChar = funcToCheck.getName().prefix(1) and
    initialChar.toUpperCase() = initialChar
  ) and
  
  // Restrict reporting to only one such function per source file
  not exists(Function anotherFunc |
    anotherFunc != funcToCheck and
    anotherFunc.getLocation().getFile() = funcToCheck.getLocation().getFile() and
    exists(string initialChar |
      initialChar = anotherFunc.getName().prefix(1) and
      initialChar.toUpperCase() = initialChar
    )
  )
select funcToCheck, "Function names should start in lowercase."