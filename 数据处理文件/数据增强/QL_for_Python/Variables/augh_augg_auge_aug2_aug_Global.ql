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

from Global nonModuleGlobalVar
where 
    // Filter out global declarations at module level
    // We only want to identify globals used in non-module contexts
    exists(Scope currentScope | 
        currentScope = nonModuleGlobalVar.getScope() and
        not currentScope instanceof Module
    )
select nonModuleGlobalVar, 
    "Modifying global variables outside of module initialization is considered a bad practice."