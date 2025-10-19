/**
 * @name Misnamed class
 * @description Identifies classes with lowercase initial letters, which violates naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Check if class name starts with lowercase letter
predicate isMisnamedClass(Class cls) {
  exists(string firstChar |
    firstChar = cls.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// Find classes violating naming conventions
from Class cls
where
  cls.inSource() and
  isMisnamedClass(cls) and
  // Ensure no other misnamed classes exist in the same file
  not exists(Class anotherClass |
    anotherClass != cls and
    anotherClass.getLocation().getFile() = cls.getLocation().getFile() and
    isMisnamedClass(anotherClass)
  )
select cls, "Class names should start in uppercase."