/**
 * @name Use of the 'global' statement.
 * @description Detects usage of the 'global' statement within functions or methods,
 *              which may indicate poor modularity and make code harder to understand and maintain.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify all global variable declarations in the code
from Global globalVar
// Filter out global statements that are not at the module level,
// as these are the ones that could potentially cause modularity issues
where not globalVar.getScope() instanceof Module
// Report the global statement with a warning message about discouraged usage
select globalVar, "Updating global variables except at module initialization is discouraged."