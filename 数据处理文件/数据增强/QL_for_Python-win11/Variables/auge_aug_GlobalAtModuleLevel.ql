/**
 * @name Use of 'global' at module level
 * @description Identifies redundant 'global' statements used at module level in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import the Python module for code analysis
import python

// Find global variable declarations that are redundant at module scope
from Global moduleLevelGlobal
where 
    // Check if the global declaration is at module level
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // Create a warning message about the redundant global declaration
    "Declaring '" + moduleLevelGlobal.getAName() + "' as global at module-level is redundant."