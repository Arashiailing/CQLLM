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

// Select expressions with detailed location information, their resolved definitions, and definition categories
from NiceLocationExpr usageExpr, Definition resolvedDefinition, string defCategory
// Filter to ensure that the resolved definition correctly matches the usage expression
// and verify type compatibility between the usage and its definition
where 
  resolvedDefinition = definitionOf(usageExpr, defCategory)
// Return the usage location, definition location, and definition category to enable navigation
select usageExpr, resolvedDefinition, defCategory