/**
 * @name Detection of non-module global variable usage.
 * @description Identifies instances where the 'global' keyword is used outside of module scope,
 *              which can lead to code that is difficult to maintain and understand.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query detects global variable declarations that occur outside module scope.
// Using global variables within functions or classes can lead to unpredictable behavior
// and maintenance challenges. Best practice dictates that global variables should be
// defined and used at the module level only.
from Global globalVarOutsideModule
// Filter condition: Verify that the global variable declaration is not within module scope
// This includes declarations inside functions, methods, or other non-module code blocks
where not globalVarOutsideModule.getScope() instanceof Module
// Result output: Display global variable declarations outside module scope with a warning
select globalVarOutsideModule, "Modifying global variables outside of module initialization is considered a bad practice."