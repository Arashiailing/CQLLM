/**
 * @name Misnamed class
 * @description Detects classes that begin with lowercase letters, which contradicts standard naming conventions
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-class
 * @tags maintainability
 */

import python

// Helper predicate to identify classes whose names start with lowercase letters
predicate is_lowercase_initial_class(Class problematicClass) {
  // Extract the initial character and verify it is not uppercase
  exists(string initialChar |
    initialChar = problematicClass.getName().prefix(1) and
    not initialChar = initialChar.toUpperCase()
  )
}

// Query to locate classes that violate naming conventions
from Class targetClass
where
  targetClass.inSource() and
  is_lowercase_initial_class(targetClass) and
  // Ensure this is the sole misnamed class within its containing file
  not exists(Class siblingClass |
    siblingClass != targetClass and
    siblingClass.getLocation().getFile() = targetClass.getLocation().getFile() and
    is_lowercase_initial_class(siblingClass)
  )
select targetClass, "Class names should start in uppercase."