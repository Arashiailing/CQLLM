/**
 * @name Navigate to Definitions
 * @description Advanced navigation utility that traces expressions in Python code to their origin definitions,
 *              facilitating code comprehension and maintenance by providing precise location mapping.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python library for comprehensive static analysis of Python source code
import python

// Import the definition tracking module to enable precise tracing of variable, function, and class definitions
import analysis.DefinitionTracking

// Select source expressions with precise location information, their corresponding definitions, and the category of each definition
from NiceLocationExpr sourceExpr, Definition correspondingDefinition, string defCategory
// Ensure that the expression has a valid corresponding definition and that their types are compatible
where 
  // Establish the relationship between the expression and its definition
  correspondingDefinition = definitionOf(sourceExpr, defCategory)
  // Verify that both the expression and its definition have valid locations
  and exists(sourceExpr.getLocation())
  and exists(correspondingDefinition.getLocation())
// Output the source expression location, corresponding definition location, and definition category for navigation purposes
select sourceExpr, correspondingDefinition, defCategory