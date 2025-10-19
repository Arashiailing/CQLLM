/**
 * @name Navigate to Definitions
 * @description Helper query for navigating from expression usage to corresponding definition locations in Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the essential Python library for performing static analysis on Python source code
import python

// Import the definition tracking functionality to trace variables, functions, and class definitions
import analysis.DefinitionTracking

// Define variables representing the expression usage, its resolved definition, and definition category
from NiceLocationExpr exprUsage, Definition targetDefinition, string definitionCategory
// Establish the relationship between usage and definition by ensuring the target definition
// correctly corresponds to the expression usage and maintaining type compatibility
where 
  targetDefinition = definitionOf(exprUsage, definitionCategory)
// Return the expression usage, its corresponding definition, and definition category
// to enable navigation from usage sites to their definitions in the codebase
select exprUsage, targetDefinition, definitionCategory