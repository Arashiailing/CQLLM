/**
 * @name Detection of non-module global variable usage
 * @description Identifies global keyword usage outside module scope. 
 *              Such usage can lead to maintainability issues and code confusion.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

from Global globalVarOutsideModule
where 
    // Exclude global declarations at module level
    not globalVarOutsideModule.getScope() instanceof Module
select globalVarOutsideModule, 
    "Modifying global variables outside of module initialization is considered a bad practice."