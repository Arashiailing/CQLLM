/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate to identify classes starting with lowercase letters
predicate lower_case_class(Class cls) {
  // Extract first character and verify it's not uppercase
  exists(string firstChar |
    firstChar = cls.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// Identify classes violating naming conventions
from Class cls
where
  cls.inSource() and
  lower_case_class(cls) and
  // Ensure this is the only misnamed class in its file
  not exists(Class anotherClass |
    anotherClass != cls and
    anotherClass.getLocation().getFile() = cls.getLocation().getFile() and
    lower_case_class(anotherClass)
  )
select cls, "Class names should start in uppercase."