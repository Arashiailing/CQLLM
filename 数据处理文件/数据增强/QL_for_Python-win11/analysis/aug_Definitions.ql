/**
 * @name Definitions
 * @description Helper query to navigate from usage to definition locations in Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the Python library for analyzing Python source code
import python

// Import the definition tracking module to trace variable and function definitions
import analysis.DefinitionTracking

// Select expressions with nice locations, their corresponding definitions, and definition types
from NiceLocationExpr usage, Definition definition, string definitionType
// Filter to ensure the definition matches the usage and the types are consistent
where definition = definitionOf(usage, definitionType)
// Return the usage location, definition location, and definition type
select usage, definition, definitionType