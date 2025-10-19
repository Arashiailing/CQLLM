/**
 * @name Definitions
 * @description Enhanced jump-to-definition helper query for Python code analysis.
 *               This query identifies the relationship between code usage locations
 *               and their corresponding definitions, enabling navigation from usage
 *               to definition in the codebase.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python library for handling Python code analysis
import python

// Import definition tracking module to trace variables and function definitions
import analysis.DefinitionTracking

// Select usage locations, their corresponding definitions, and definition types
from NiceLocationExpr usageLocation, Definition definitionLocation, string definitionType
// Establish relationship: the definition must correspond to the usage with matching type
where definitionLocation = definitionOf(usageLocation, definitionType)
// Output the usage location, its definition location, and the type of definition
select usageLocation, definitionLocation, definitionType