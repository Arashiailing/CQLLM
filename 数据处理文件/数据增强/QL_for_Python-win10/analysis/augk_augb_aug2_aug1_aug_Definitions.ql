/**
 * @name Navigate to Definitions
 * @description Provides precise navigation from Python expressions to their origin definitions,
 *              enhancing code understanding through accurate location mapping.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import essential Python analysis capabilities for static code examination
import python

// Enable definition tracking to trace variables, functions, and classes to their sources
import analysis.DefinitionTracking

// Query expressions that have valid locations and corresponding definitions
from NiceLocationExpr refExpr, Definition matchedDef, string definitionType
where 
  // Link expression to its definition and ensure both have valid locations
  matchedDef = definitionOf(refExpr, definitionType)
  and exists(refExpr.getLocation())
  and exists(matchedDef.getLocation())
// Present navigation data: expression, its definition, and definition type
select refExpr, matchedDef, definitionType