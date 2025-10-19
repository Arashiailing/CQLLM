/**
 * @name Definitions
 * @description A helper query that enables navigation from expressions to their definitions.
 *              This identifies relationships between code usages and their corresponding
 *              definitions, supporting jump-to-definition functionality in IDEs.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis capabilities for examining Python source code
import python

// Import definition tracking functionality to resolve variable and function references
import analysis.DefinitionTracking

// Query for expressions with location information, their definitions, and definition types
from NiceLocationExpr expressionUsage, Definition definitionRef, string definitionKind
// Establish relationship between usage and definition, ensuring they match by type
where definitionRef = definitionOf(expressionUsage, definitionKind)
// Output the usage location, corresponding definition location, and definition type
select expressionUsage, definitionRef, definitionKind