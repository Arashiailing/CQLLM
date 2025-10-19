/**
 * @name Use of the 'global' statement.
 * @description Identifies global variable declarations that occur outside module scope.
 *              Global variables used within functions or classes can lead to code that is
 *              difficult to maintain, test, and reason about due to implicit dependencies.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify all global variable declarations in the codebase
from Global globalVariableOutsideModule
// Filter for global variables that are not declared at the module level
// This helps detect globals that might be used in functions or methods, which is discouraged
where not globalVariableOutsideModule.getScope() instanceof Module
// Return the global variable declaration with a warning message
select globalVariableOutsideModule, "Updating global variables except at module initialization is discouraged."