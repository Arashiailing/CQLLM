/**
 * @name Navigate to Definitions
 * @description A utility for tracing Python expressions back to their source definitions,
 *              facilitating rapid code navigation and enhancing code comprehension.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis framework for static code inspection
import python

// Integrate definition tracking functionality to trace variables, functions, and class declarations
import analysis.DefinitionTracking

// Identify expressions with location data, their corresponding source definitions, and definition categories
from NiceLocationExpr sourceExpr, Definition sourceDef, string defCategory
// Ensure expressions are properly linked to definitions with valid location information
where 
  // Establish the relationship between expression and its source definition
  sourceDef = definitionOf(sourceExpr, defCategory)
  // Validate that both expression and definition contain verifiable location data
  and exists(sourceExpr.getLocation()) and exists(sourceDef.getLocation())
// Present the reference expression location, source definition location, and definition classification
select sourceExpr, sourceDef, defCategory