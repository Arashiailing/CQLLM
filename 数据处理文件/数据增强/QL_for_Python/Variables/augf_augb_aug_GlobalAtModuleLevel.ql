/**
 * @name Redundant module-level global declarations
 * @description Identifies unnecessary 'global' declarations at module scope in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import the Python analysis module
import python

// Identify redundant global declarations at module scope
from Global redundantGlobal
where 
    // Verify the declaration is at module level
    exists(Scope scope | 
        scope = redundantGlobal.getScope() and 
        scope instanceof Module
    )
select 
    redundantGlobal, 
    // Generate warning message for redundant declaration
    "Redundant global declaration of '" + redundantGlobal.getAName() + "' at module level."