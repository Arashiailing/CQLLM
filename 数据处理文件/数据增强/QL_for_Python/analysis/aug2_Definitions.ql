/**
 * @name Definitions
 * @description A helper query for navigating from usage to definition in Python code.
 *              This query identifies the definition that corresponds to a given usage,
 *              enabling IDE features like "Go to Definition".
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
from NiceLocationExpr usedExpr, Definition targetDefn, string definitionKind
// Filter results where:
//   - The target definition is the one that defines the used expression
//   - The definition kind matches the expected type
where targetDefn = definitionOf(usedExpr, definitionKind)
// Output the used expression location, its definition location, and the definition kind
select usedExpr, targetDefn, definitionKind