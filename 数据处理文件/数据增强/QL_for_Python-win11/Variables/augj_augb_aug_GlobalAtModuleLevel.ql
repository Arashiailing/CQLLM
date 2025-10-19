/**
 * @name Redundant module-level global declarations
 * @description Identifies redundant 'global' keyword usage at module scope in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis framework
import python

// Identify global declarations that are redundant at module level
from Global redundantGlobalStmt
where 
    // Verify the global statement is at module scope
    redundantGlobalStmt.getScope() instanceof Module
select 
    redundantGlobalStmt, 
    // Construct warning message for the redundant global declaration
    "Redundant global declaration of '" + redundantGlobalStmt.getAName() + "' at module level."