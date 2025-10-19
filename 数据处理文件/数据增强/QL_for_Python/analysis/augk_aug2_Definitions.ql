/**
 * @name Definitions
 * @description Enhanced navigation helper for locating definitions from usage points in Python.
 *              This query establishes the mapping between code references and their source definitions,
 *              facilitating IDE navigation features such as "Go to Definition".
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python language library for comprehensive source code analysis
import python

// Import definition tracking utilities to correlate references with their originating definitions
import analysis.DefinitionTracking

// Define the main query components:
//   - referencedExpr: Expression being referenced in the code
//   - originDefn: The source definition that defines the referenced expression
//   - defType: Category or type of the definition being referenced
from NiceLocationExpr referencedExpr, Definition originDefn, string defType
// Establish the relationship where the origin definition corresponds to the referenced expression
// and matches the expected definition type
where originDefn = definitionOf(referencedExpr, defType)
// Return the referenced expression, its originating definition, and the definition type
select referencedExpr, originDefn, defType