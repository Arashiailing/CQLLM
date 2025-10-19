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

// Detect all redundant global variable declarations located at module scope
// The 'global' keyword is unnecessary at module level since variables have global scope by default
from Global moduleLevelGlobal
where 
    // Confirm that the global declaration exists within module-level scope
    // Variables defined at module level automatically have global scope
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // Create warning message highlighting the redundant global declaration
    "Redundant global declaration: '" + moduleLevelGlobal.getAName() + "' at module level is unnecessary."