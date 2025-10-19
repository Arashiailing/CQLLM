/**
 * @name Misnamed class
 * @description Identifies classes violating Python naming conventions by starting with lowercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Helper predicate to check if a class name starts with a lowercase character
predicate startsWithLowercase(Class targetClass) {
  exists(string firstChar |
    firstChar = targetClass.getName().prefix(1) and
    firstChar != firstChar.toUpperCase()
  )
}

// Main query to find classes violating naming conventions
from Class targetClass
where
  targetClass.inSource() and
  startsWithLowercase(targetClass) and
  // Ensure this is the only misnamed class in its containing file
  not exists(Class otherClass |
    otherClass.getLocation().getFile() = targetClass.getLocation().getFile() and
    startsWithLowercase(otherClass) and
    otherClass != targetClass
  )
select targetClass, "Class names should start with uppercase letters."