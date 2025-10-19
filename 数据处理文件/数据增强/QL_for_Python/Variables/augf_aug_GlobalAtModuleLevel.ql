/**
 * @name Redundant Global Declaration at Module Level
 * @description Detects unnecessary 'global' statements used at module scope in Python code,
 *              as all module-level variables are inherently global.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis module
import python

// Find global declarations at module level
from Global moduleLevelGlobal
where 
    // Check if the global declaration is in module scope
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // Create warning message for the redundant global declaration
    "Redundant global declaration of '" + moduleLevelGlobal.getAName() + "' at module level."