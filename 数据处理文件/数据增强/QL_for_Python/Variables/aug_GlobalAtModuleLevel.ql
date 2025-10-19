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

// Import Python module for code analysis
import python

// Identify global variables declared at module level
from Global redundantGlobal
where 
    // Filter for globals declared at module scope
    redundantGlobal.getScope() instanceof Module
select 
    redundantGlobal, 
    // Generate warning message for redundant global declaration
    "Declaring '" + redundantGlobal.getAName() + "' as global at module-level is redundant."