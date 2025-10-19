/**
 * @name Navigate to Definitions
 * @description Enhanced navigation utility that traces Python expressions to their origin definitions,
 *              enabling precise code comprehension through accurate location mapping.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis framework for comprehensive static code examination
import python

// Import definition tracking module to enable precise tracing of variables, functions, and classes
import analysis.DefinitionTracking

// Select source expressions with location data, their resolved definitions, and definition categories
from NiceLocationExpr sourceExpression, Definition targetDefinition, string definitionCategory
// Validate expression-definition relationships and location availability
where 
  // Establish semantic link between expression and its origin definition
  targetDefinition = definitionOf(sourceExpression, definitionCategory)
  // Ensure both expression and definition have valid location metadata
  and exists(sourceExpression.getLocation())
  and exists(targetDefinition.getLocation())
// Output expression location, definition location, and category for navigation
select sourceExpression, targetDefinition, definitionCategory