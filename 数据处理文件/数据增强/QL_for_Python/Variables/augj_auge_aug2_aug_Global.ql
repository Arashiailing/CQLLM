/**
 * @name Non-module global variable usage
 * @description Detects 'global' keyword usage outside module scope,
 *              which can cause maintainability issues and code confusion.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global declarations occurring outside module scope
from Global globalVarOutsideModule, Scope currentScope
where 
    currentScope = globalVarOutsideModule.getScope() and
    not currentScope instanceof Module
// Report the problematic global declaration
select globalVarOutsideModule, "Modifying global variables outside of module initialization is considered a bad practice."