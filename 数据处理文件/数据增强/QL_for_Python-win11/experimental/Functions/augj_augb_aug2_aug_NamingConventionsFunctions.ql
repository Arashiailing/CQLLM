/**
 * @name Misnamed function
 * @description Identifies functions with names starting with an uppercase letter, which violates Python naming conventions and reduces code readability.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @coding-standard Python PEP 8
 */

import python

/**
 * Determines if a function's name begins with an uppercase letter.
 * This predicate checks the first character of the function name to verify
 * if it is uppercase, which violates Python's PEP 8 naming conventions.
 * @param targetFunction The function to check for naming convention violations.
 * @returns true if the function's name starts with an uppercase letter, false otherwise.
 */
predicate startsWithUppercaseLetter(Function targetFunction) {
  exists(string firstCharacter |
    firstCharacter = targetFunction.getName().prefix(1) and
    firstCharacter.toUpperCase() = firstCharacter
  )
}

/**
 * Finds functions that violate Python naming conventions by starting with an uppercase letter.
 * The query focuses on isolated violations by excluding cases where multiple functions
 * in the same file share the same naming pattern, which might indicate an intentional
 * design choice rather than an oversight.
 */
from Function problematicFunction
where
  problematicFunction.inSource() and
  startsWithUppercaseLetter(problematicFunction) and
  not exists(Function otherFunction |
    otherFunction != problematicFunction and
    otherFunction.getLocation().getFile() = problematicFunction.getLocation().getFile() and
    startsWithUppercaseLetter(otherFunction)
  )
select problematicFunction, "Function names should start with a lowercase letter according to PEP 8 naming conventions."