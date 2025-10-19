/**
 * @name Misnamed class
 * @description Detects classes violating naming conventions by starting with lowercase letters
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate identifying classes with lowercase initial characters
predicate isMisnamedClass(Class cls) {
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
  isMisnamedClass(cls) and
  // Ensure this is the only misnamed class in its file
  not exists(Class otherCls |
    otherCls != cls and
    otherCls.getLocation().getFile() = cls.getLocation().getFile() and
    isMisnamedClass(otherCls)
  )
select cls, "Class names should start in uppercase."