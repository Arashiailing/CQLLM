/**
 * @name Misnamed function
 * @description Identifies functions violating Python naming conventions by detecting 
 *              functions that begin with a capital letter and are the only such function 
 *              in their source file.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

// Identify functions with naming convention violations
from Function misnamedFunctionCandidate
where
  // Ensure the function is part of the source code
  misnamedFunctionCandidate.inSource() and
  // Check if the function name starts with an uppercase letter
  exists(string firstChar |
    firstChar = misnamedFunctionCandidate.getName().prefix(1) and
    firstChar.toUpperCase() = firstChar
  ) and
  // Verify this is the only function with capitalizedName in its file
  count(Function peerFunction |
    peerFunction.getLocation().getFile() = misnamedFunctionCandidate.getLocation().getFile() and
    exists(string peerFirstChar |
      peerFirstChar = peerFunction.getName().prefix(1) and
      peerFirstChar.toUpperCase() = peerFirstChar
    )
  ) = 1
select misnamedFunctionCandidate, "Function names should start in lowercase."