/**
 * @name Misnamed class
 * @description Identifies classes that violate naming conventions by starting with lowercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Identify classes violating naming conventions
from Class targetClass
where
  // Ensure class is in source code
  targetClass.inSource() and
  // Check if class name starts with lowercase
  exists(string initialChar |
    initialChar = targetClass.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  ) and
  // Verify this is the only misnamed class in its file
  not exists(Class otherClass |
    otherClass != targetClass and
    otherClass.getLocation().getFile() = targetClass.getLocation().getFile() and
    // Check if other class also has lowercase initial
    exists(string otherInitialChar |
      otherInitialChar = otherClass.getName().prefix(1) and
      not otherInitialChar = otherInitialChar.toUpperCase()
    )
  )
select targetClass, "Class names should start in uppercase."