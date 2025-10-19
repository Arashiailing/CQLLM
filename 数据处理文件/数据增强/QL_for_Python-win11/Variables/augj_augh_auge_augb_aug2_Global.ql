/**
 * @name Usage of 'global' keyword in Python code.
 * @description Identifies instances where 'global' statements are used in non-module scopes, 
 *              potentially indicating a design that lacks proper modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global statements and their containing scopes
from Global globalStmt, Scope parentScope

// Filter global statements defined outside module scopes
where 
  globalStmt.getScope() = parentScope
  and not parentScope instanceof Module

// Report global statements violating modularity principles
select globalStmt, "Modifying global variables outside of module initialization is not recommended."