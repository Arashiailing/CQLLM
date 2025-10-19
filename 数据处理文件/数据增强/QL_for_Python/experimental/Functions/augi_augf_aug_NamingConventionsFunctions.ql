/**
 * @name Misnamed function
 * @description Detects functions that begin with a capital letter, 
 *              which contradicts Python naming standards and affects code clarity.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 */

import python

from Function examinedFunction
where
  // Verify the function is defined in source code
  examinedFunction.inSource() and
  
  // Check if the function name starts with an uppercase letter
  exists(string nameInitial |
    nameInitial = examinedFunction.getName().prefix(1) and
    not nameInitial = nameInitial.toLowerCase()
  ) and
  
  // Ensure this is the only function with this naming issue in the file
  not exists(Function otherFunction |
    otherFunction != examinedFunction and
    otherFunction.getLocation().getFile() = examinedFunction.getLocation().getFile() and
    // Check if the other function also starts with uppercase
    exists(string otherNameInitial |
      otherNameInitial = otherFunction.getName().prefix(1) and
      not otherNameInitial = otherNameInitial.toLowerCase()
    )
  )
select examinedFunction, "Function names should start in lowercase."