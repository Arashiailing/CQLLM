/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate to identify classes that violate naming conventions
// by not starting with an uppercase letter
predicate violatesNamingConvention(Class cls) {
  // Extract and validate the first character of the class name
  exists(string firstChar |
    firstChar = cls.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// Find classes that break naming conventions
from Class misnamedClass
where
  // Ensure the class is part of the source code
  misnamedClass.inSource() and
  // Check if the class name violates naming conventions
  violatesNamingConvention(misnamedClass) and
  // Verify this is the only misnamed class in its source file
  not exists(Class otherMisnamedClass |
    otherMisnamedClass != misnamedClass and
    otherMisnamedClass.getLocation().getFile() = misnamedClass.getLocation().getFile() and
    violatesNamingConvention(otherMisnamedClass)
  )
select misnamedClass, "Class names should start in uppercase."