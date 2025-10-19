/**
 * @name Use of the 'global' statement.
 * @description Detects usage of global statements outside module scope, which can lead to poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variable declarations not at module level
from Global globalStmt
where 
  // Filter out global statements at module initialization scope
  not globalStmt.getScope() instanceof Module
select 
  globalStmt, 
  "Updating global variables except at module initialization is discouraged."