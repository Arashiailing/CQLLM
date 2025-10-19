/**
 * @name Navigate to Definitions
 * @description Enhanced helper query for navigating from expression usage to their corresponding definition locations in Python source code.
 * @kind definitions
 * @id py/jump-to-definition */

// Import the core Python library for static analysis of Python source code
import python

// Import the definition tracking module to enable tracing of variable, function, and class definitions
import analysis.DefinitionTracking

// This query establishes a mapping between expressions in Python code and their definitions
from NiceLocationExpr sourceExpr, Definition targetDef, string defCategory
// Resolve the definition associated with the source expression
where 
  targetDef = definitionOf(sourceExpr, defCategory)
// Return the source expression, its definition, and the definition category for navigation
select sourceExpr, targetDef, defCategory