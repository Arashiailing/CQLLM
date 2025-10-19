/**
 * @name Definition Navigator
 * @description This query facilitates navigation from expression references to their corresponding source definitions in Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python analysis library for source code examination
import python

// Import the definition tracking module to trace variable, function, and class definitions
import analysis.DefinitionTracking

// Locate expressions with position details, their associated definitions, and definition types
from NiceLocationExpr referencedExpr, Definition sourceDefinition, string definitionType
// Ensure the definition correctly corresponds to the usage and preserves type consistency
where 
  sourceDefinition = definitionOf(referencedExpr, definitionType)
// Display the reference position, definition position, and definition type for navigation purposes
select referencedExpr, sourceDefinition, definitionType