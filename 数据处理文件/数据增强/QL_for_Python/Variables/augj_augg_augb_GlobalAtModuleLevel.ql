/**
 * @name Use of 'global' at module level
 * @description Identifies redundant 'global' statements at module level, as module-level variables are inherently global
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis library for parsing and accessing Python syntax structures
import python

// Search for variables declared with the 'global' keyword at module level
// In Python, variables defined at module scope are global by default, making explicit 'global' declarations redundant
from Global moduleLevelGlobal
where 
    // Verify that the global declaration is within module scope
    // Module-level variables are naturally global without requiring additional declarations
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // Generate warning message to inform developers about the unnecessary global declaration
    "Redundant global declaration of '" + moduleLevelGlobal.getAName() + "' at module-level."