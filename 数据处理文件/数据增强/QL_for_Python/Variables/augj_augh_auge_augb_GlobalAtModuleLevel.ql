/**
 * @name Redundant 'global' statement at module level
 * @description Identifies unnecessary use of the 'global' keyword at module scope in Python.
 *              Module-level variables are inherently global, making explicit declarations redundant.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis library for accessing code structure and semantic information
import python

// Identify redundant global declarations at module scope
// Module-level variables are global by default, making explicit 'global' declarations unnecessary
from Global redundantGlobal
where 
    // Verify the global declaration exists within module-level scope
    redundantGlobal.getScope() instanceof Module
select 
    redundantGlobal, 
    // Generate warning message for the redundant global declaration
    "Redundant global declaration: '" + redundantGlobal.getAName() + "' at module level is unnecessary."