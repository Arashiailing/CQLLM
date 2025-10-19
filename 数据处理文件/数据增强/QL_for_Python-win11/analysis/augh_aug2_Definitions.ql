/**
 * @name Definitions
 * @description Facilitates navigation from usage to definition in Python code.
 *              Identifies the definition corresponding to a given usage,
 *              supporting IDE features like "Go to Definition".
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python language library for analyzing Python source code
import python

// Import definition tracking module to establish relationships between 
// usages and their corresponding definitions
import analysis.DefinitionTracking

// Select expressions with location information, their corresponding definitions,
// and the kind of definition being referenced
from NiceLocationExpr referencedExpr, Definition sourceDefinition, string defType
// Filter results where:
//   - The source definition is the one that defines the referenced expression
//   - The definition type matches the expected category
where sourceDefinition = definitionOf(referencedExpr, defType)
// Output the referenced expression location, its definition location, and the definition type
select referencedExpr, sourceDefinition, defType