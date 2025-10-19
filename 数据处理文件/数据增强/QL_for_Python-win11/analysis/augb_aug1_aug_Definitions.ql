/**
 * @name Definition Navigator
 * @description Utility query enabling navigation from code references to their source definitions in Python projects.
 * @kind definitions
 * @id py/definition-navigator
 */

// Import the essential Python analysis library for examining Python source code
import python

// Import the definition tracking component to facilitate tracing of variables, functions, and class declarations
import analysis.DefinitionTracking

// Extract expressions with location data, their corresponding definitions, and definition classifications
from NiceLocationExpr codeRef, Definition sourceDef, string defCategory
// Validate that the definition properly matches the reference and maintains type compatibility
where sourceDef = definitionOf(codeRef, defCategory)
// Present the reference location, definition location, and definition category for navigation support
select codeRef, sourceDef, defCategory