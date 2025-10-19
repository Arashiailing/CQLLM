/**
 * @name Use of the 'global' statement.
 * @description Detects 'global' declarations outside module scope, which may lead to code maintainability issues.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query identifies global variable declarations that are not at the module level,
// which can be a sign of poor code organization and make the code harder to maintain.
from Global globalDecl
where 
  // Check if the global declaration is not at the module scope
  not globalDecl.getScope() instanceof Module
// We report each non-module global declaration with a message discouraging this practice.
select globalDecl, "Usage of global variables outside of module initialization is considered bad practice and is discouraged."