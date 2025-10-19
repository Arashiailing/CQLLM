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
predicate has_lowercase_initial(Class misnamedClass) {
  // Extract first character and verify it's not uppercase
  exists(string firstChar |
    firstChar = misnamedClass.getName().prefix(1) and
    not firstChar = firstChar.toUpperCase()
  )
}

// Identify classes violating naming conventions
from Class misnamedClass
where
  misnamedClass.inSource() and
  has_lowercase_initial(misnamedClass) and
  // Ensure this is the only misnamed class in its file
  not exists(Class anotherMisnamedClass |
    anotherMisnamedClass != misnamedClass and
    anotherMisnamedClass.getLocation().getFile() = misnamedClass.getLocation().getFile() and
    has_lowercase_initial(anotherMisnamedClass)
  )
select misnamedClass, "Class names should start in uppercase."