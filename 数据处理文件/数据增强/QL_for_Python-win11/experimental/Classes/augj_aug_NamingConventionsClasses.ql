/**
 * @name Misnamed class
 * @description Detects classes violating naming conventions by starting with lowercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Helper predicate to identify classes with lowercase initial characters
predicate hasLowerCaseInitial(Class cls) {
  // Check if the first character of the class name is not uppercase
  exists(string initialChar |
    initialChar = cls.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  )
}

// Main query to find isolated naming violations
from Class misnamedClass
where
  misnamedClass.inSource() and
  hasLowerCaseInitial(misnamedClass) and
  // Verify no other misnamed classes exist in the same file
  not exists(Class otherMisnamedClass |
    otherMisnamedClass != misnamedClass and
    otherMisnamedClass.getLocation().getFile() = misnamedClass.getLocation().getFile() and
    hasLowerCaseInitial(otherMisnamedClass)
  )
select misnamedClass, "Class names should start in uppercase."