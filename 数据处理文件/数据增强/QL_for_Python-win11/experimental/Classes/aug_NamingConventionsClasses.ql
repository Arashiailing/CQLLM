/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate to detect classes starting with lowercase letters
predicate lower_case_class(Class targetClass) {
  // Extract first character and verify it's not uppercase
  exists(string initialChar |
    initialChar = targetClass.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  )
}

// Identify classes violating naming conventions
from Class targetClass
where
  targetClass.inSource() and
  lower_case_class(targetClass) and
  // Ensure this is the only misnamed class in its file
  not exists(Class otherClass |
    otherClass != targetClass and
    otherClass.getLocation().getFile() = targetClass.getLocation().getFile() and
    lower_case_class(otherClass)
  )
select targetClass, "Class names should start in uppercase."