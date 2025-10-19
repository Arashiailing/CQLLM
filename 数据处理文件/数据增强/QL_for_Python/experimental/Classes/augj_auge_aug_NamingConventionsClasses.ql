/**
 * @name Misnamed class
 * @description Detects classes that violate Python naming conventions by starting with lowercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Identify classes with improper naming convention
// Specifically targeting classes whose names begin with lowercase letters
from Class problematicClass
where
  // Ensure we only analyze classes defined in source code
  problematicClass.inSource() and
  // Check if class name starts with lowercase letter
  exists(string initialChar |
    initialChar = problematicClass.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  ) and
  // Filter to report only the single violation per source file
  // This avoids flagging multiple classes in the same file
  not exists(Class anotherClass |
    anotherClass != problematicClass and
    anotherClass.getLocation().getFile() = problematicClass.getLocation().getFile() and
    exists(string anotherInitialChar |
      anotherInitialChar = anotherClass.getName().prefix(1) and
      not anotherInitialChar = anotherInitialChar.toUpperCase()
    )
  )
select problematicClass, "Class names should start in uppercase."