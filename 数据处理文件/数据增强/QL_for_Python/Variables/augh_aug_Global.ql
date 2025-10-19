/**
 * @name Non-module scope global variable usage
 * @description Identifies global variable declarations that are not at the module level.
 *              Using global variables outside module scope can reduce code modularity
 *              and make maintenance more difficult.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query finds global variable declarations that are not at module scope
from Global globalVariableDeclaration
where 
    // Exclude global variables declared at module level
    not globalVariableDeclaration.getScope() instanceof Module
select 
    globalVariableDeclaration, 
    "Updating global variables except at module initialization is discouraged."