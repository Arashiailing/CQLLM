/**
 * @name Navigate to Definitions
 * @description Advanced navigation query that maps Python expressions to their corresponding definitions,
 *              enabling precise code navigation and understanding of symbol resolution.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python library for comprehensive static analysis capabilities
import python

// Import definition tracking functionality to establish relationships between code usage and definitions
import analysis.DefinitionTracking

// Source expression in the code that references a definition
from NiceLocationExpr sourceExpression, 
     // Resolved definition that the source expression points to
     Definition resolvedDefinition, 
     // Categorization of the definition type (variable, function, class, etc.)
     string definitionCategory
// Establish the relationship between the expression and its definition
where 
  // Resolve the definition for the given expression and determine its category
  resolvedDefinition = definitionOf(sourceExpression, definitionCategory)
// Return the source expression, its resolved definition, and the definition category for navigation
select sourceExpression, resolvedDefinition, definitionCategory