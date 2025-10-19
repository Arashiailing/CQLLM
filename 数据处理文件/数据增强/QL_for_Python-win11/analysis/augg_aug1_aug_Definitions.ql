/**
 * @name Navigate to Definitions
 * @description Enhanced helper query for navigating from expression usage to their corresponding definition locations in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis capabilities for static source code examination
import python

// Import definition tracking functionality to trace variable, function, and class declarations
import analysis.DefinitionTracking

// Select usage expressions with precise locations, their corresponding definitions, and definition categories
from NiceLocationExpr usageExpr, Definition targetDefinition, string definitionKind
// Ensure the definition correctly corresponds to the usage with compatible types
where 
  targetDefinition = definitionOf(usageExpr, definitionKind)
// Output usage location, definition location, and definition type for navigation
select usageExpr, targetDefinition, definitionKind