/**
 * @name Navigate to Definitions
 * @description Enhanced navigation utility that traces Python expressions to their source definitions,
 *              enabling efficient code comprehension and maintenance through precise location mapping.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python library for comprehensive static analysis of Python source code
import python

// Import the definition tracking module to enable precise tracing of variable, function, and class definitions
import analysis.DefinitionTracking

// Select target expressions with their corresponding source definitions and definition categories
from NiceLocationExpr targetExpr, Definition sourceDefinition, string definitionCategory
where 
  // Establish the relationship between the expression and its source definition
  sourceDefinition = definitionOf(targetExpr, definitionCategory)
  // Verify that both the expression and its definition have valid locations
  and exists(targetExpr.getLocation())
  and exists(sourceDefinition.getLocation())
// Output the target expression, source definition location, and definition category for navigation purposes
select targetExpr, sourceDefinition, definitionCategory