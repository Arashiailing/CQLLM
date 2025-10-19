/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Identify classes violating naming conventions
from Class targetClass
where
  // Only consider classes present in source code
  targetClass.inSource() and
  // Check if class name starts with lowercase letter
  exists(string initialChar |
    initialChar = targetClass.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  ) and
  // Ensure this is the only misnamed class in its file
  not exists(Class otherClass |
    otherClass != targetClass and
    otherClass.getLocation().getFile() = targetClass.getLocation().getFile() and
    // Verify other class also violates naming convention
    exists(string otherInitialChar |
      otherInitialChar = otherClass.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toUpperCase()
    )
  )
select targetClass, "Class names should start in uppercase."