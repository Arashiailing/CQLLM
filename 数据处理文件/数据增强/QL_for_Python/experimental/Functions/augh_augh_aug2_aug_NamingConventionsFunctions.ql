/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, 
 *              which violates Python naming conventions and reduces code readability.
 *              This query reports only one such function per file when multiple exist
 *              to avoid duplicate warnings in the same file.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

from Function targetFunction
where
  // Verify the function is defined in source code (not in library files)
  targetFunction.inSource() and
  
  // Check if the function name begins with an uppercase letter
  exists(string firstCharacter |
    firstCharacter = targetFunction.getName().prefix(1) and
    firstCharacter = firstCharacter.toUpperCase()
  ) and
  
  // Ensure this is the only function with uppercase-starting name in its file
  not exists(Function otherFunction |
    otherFunction != targetFunction and
    otherFunction.getLocation().getFile() = targetFunction.getLocation().getFile() and
    exists(string firstCharacter |
      firstCharacter = otherFunction.getName().prefix(1) and
      firstCharacter = firstCharacter.toUpperCase()
    )
  )
select targetFunction, "Function names should start in lowercase."