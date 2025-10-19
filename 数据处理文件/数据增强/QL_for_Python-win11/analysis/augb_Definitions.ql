/**
 * @name Symbol Definitions
 * @description Helper query for navigating to symbol definitions in Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python module for analyzing Python source code
import python

// Import DefinitionTracking module for tracking variable and function definitions
import analysis.DefinitionTracking

// Query for finding definitions corresponding to symbol usages
from NiceLocationExpr usageLocation, Definition targetDefinition, string definitionKind
// Filter to match definitions with their corresponding usages
where targetDefinition = definitionOf(usageLocation, definitionKind)
// Return the usage location, target definition, and definition kind
select usageLocation, targetDefinition, definitionKind