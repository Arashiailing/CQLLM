/**
 * @name Python Definition Locator
 * @description Identifies and maps code usage locations to their corresponding definitions.
 *              This query serves as a jump-to-definition helper by establishing relationships
 *              between usage instances and their source definitions.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python language support module for Python code analysis
import python

// Import definition tracking capabilities for establishing usage-definition relationships
import analysis.DefinitionTracking

// Query to establish mapping between usage locations and their source definitions
from NiceLocationExpr usageLocation, Definition definitionRef, string definitionType
// Establish relationship where the definition reference corresponds to the usage location
// and maintain type consistency between usage and definition
where definitionRef = definitionOf(usageLocation, definitionType)
// Output the usage location, its corresponding definition, and the type of definition
select usageLocation, definitionRef, definitionType