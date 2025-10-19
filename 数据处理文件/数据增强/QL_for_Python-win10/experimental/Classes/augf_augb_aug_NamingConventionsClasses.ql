/**
 * @name Misnamed class
 * @description Detects classes that begin with lowercase letters, which contradicts standard Python naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Helper predicate that checks if a class name starts with a lowercase letter
predicate hasClassLowercaseInitial(Class cls) {
  exists(string initialCharacter |
    initialCharacter = cls.getName().prefix(1) and
    not initialCharacter = initialCharacter.toUpperCase()
  )
}

// Query to find classes that violate naming conventions
from Class cls
where
  cls.inSource() and
  hasClassLowercaseInitial(cls) and
  // Ensure this is the only misnamed class in its file
  not exists(Class otherClass |
    otherClass.getLocation().getFile() = cls.getLocation().getFile() and
    hasClassLowercaseInitial(otherClass) and
    otherClass != cls
  )
select cls, "Class names should start in uppercase."