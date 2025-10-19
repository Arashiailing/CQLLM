/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate to detect classes violating naming conventions
// by checking if their names start with lowercase letters
predicate violatesNamingConvention(Class targetClass) {
  // Extract first character of class name
  exists(string initialChar |
    initialChar = targetClass.getName().prefix(1) and
    // Verify character is not uppercase
    not initialChar = initialChar.toUpperCase()
  )
}

// Identify classes that break naming conventions
from Class problematicClass
where
  // Ensure class is part of source code
  problematicClass.inSource() and
  // Check for naming convention violation
  violatesNamingConvention(problematicClass) and
  // Confirm this is the sole misnamed class in its source file
  not exists(Class anotherProblematicClass |
    anotherProblematicClass != problematicClass and
    anotherProblematicClass.getLocation().getFile() = problematicClass.getLocation().getFile() and
    violatesNamingConvention(anotherProblematicClass)
  )
select problematicClass, "Class names should start in uppercase."