/**
 * @name Class with lowercase initial
 * @description Identifies classes that have names starting with a lowercase letter, which violates standard naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Predicate that checks if a class name starts with a lowercase letter
predicate is_lowercase_initial_class(Class cls) {
  // Obtain the first character of the class name and check that it is not uppercase
  exists(string firstChar |
    firstChar = cls.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// Find classes that do not follow the naming convention (starting with uppercase)
from Class violatingClass
where
  violatingClass.inSource() and
  is_lowercase_initial_class(violatingClass) and
  // Verify this is the only class with naming violation in its containing file
  not exists(Class otherClass |
    otherClass != violatingClass and
    otherClass.getLocation().getFile() = violatingClass.getLocation().getFile() and
    is_lowercase_initial_class(otherClass)
  )
select violatingClass, "Class names should start in uppercase."