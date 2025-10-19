/**
 * @name Redundant module-level global declarations
 * @description Detects unnecessary 'global' statements at module scope in Python
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

// Find global variable declarations at module level
from Global globalDecl
where 
    // Check if the global declaration is at module level
    globalDecl.getScope() instanceof Module
select 
    globalDecl, 
    // Create warning message for redundant global declaration
    "Redundant global declaration of '" + globalDecl.getAName() + "' at module level."