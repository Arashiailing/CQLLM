/**
 * @name Function Naming Convention Violation
 * @description Detects Python functions that do not adhere to PEP8 naming standards, specifically those beginning with uppercase letters.
 * @kind problem
 * @problem.severity recommendation
 * @id py/misnamed-function
 * @tags maintainability
 * @convention PEP8
 */

import python  // Import Python analysis module for code inspection capabilities

// Helper predicate to determine if a function's name begins with an uppercase letter
predicate hasCapitalizedName(Function func) {
  exists(string initialCharacter |
    initialCharacter = func.getName().prefix(1) and  // Extract the initial character of the function name
    not initialCharacter = initialCharacter.toLowerCase()  // Confirm the character is uppercase
  )
}

// Main query for identifying functions that violate PEP8 naming conventions
from Function nonCompliantFunction
where
  // Basic conditions: function is in source code and violates naming convention
  nonCompliantFunction.inSource() and
  hasCapitalizedName(nonCompliantFunction)
  
  // Additional condition: exclude files with multiple violations to reduce noise
  and not exists(Function otherFunction |
    otherFunction != nonCompliantFunction and
    otherFunction.getLocation().getFile() = nonCompliantFunction.getLocation().getFile() and
    hasCapitalizedName(otherFunction)
  )
select nonCompliantFunction, "Function names should start with lowercase letters according to PEP8."