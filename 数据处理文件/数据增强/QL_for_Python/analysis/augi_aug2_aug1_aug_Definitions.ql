/**
 * @name Definition Navigator
 * @description A specialized query that enables navigation from expression references to their source definitions within Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the essential Python analysis library for examining Python source code
import python

// Import the definition tracking functionality to follow variable, function, and class definitions
import analysis.DefinitionTracking

// Identify expressions with location information, their corresponding definitions, and definition classifications
from NiceLocationExpr usedExpr, Definition defSite, string defCategory
// Verify that the definition properly matches the usage and maintains type compatibility
where 
  defSite = definitionOf(usedExpr, defCategory)
// Present the reference location, definition location, and definition category for navigation
select usedExpr, defSite, defCategory