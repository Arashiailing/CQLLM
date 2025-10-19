/**
 * @name Navigate to Definitions
 * @description Enhanced navigation tool that maps Python expressions to their source definitions,
 *              enabling developers to quickly trace code origins and improve understanding.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import essential Python analysis framework for static code examination
import python

// Include definition tracking capabilities to accurately trace variables, functions, and class origins
import analysis.DefinitionTracking

// Identify expressions with location data, their source definitions, and classification types
from NiceLocationExpr refExpr, Definition originDefinition, string definitionType
// Validate that expressions have valid definitions with compatible types and verifiable locations
where 
  // Link expression to its originating definition
  originDefinition = definitionOf(refExpr, definitionType)
  // Confirm both expression and definition contain valid location information
  and exists(refExpr.getLocation())
  and exists(originDefinition.getLocation())
// Present reference expression location, source definition location, and definition classification
select refExpr, originDefinition, definitionType