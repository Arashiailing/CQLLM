/**
 * @name Definitions
 * @description Enhanced navigation aid for Python code that maps usage sites to their corresponding definitions.
 *               This analysis enables developers to quickly locate where variables, functions, and other
 *               code elements are defined based on their usage throughout the codebase.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis library for processing Python source code
import python

// Import definition tracking functionality to establish relationships between code usage and definitions
import analysis.DefinitionTracking

// Select expressions representing usage locations, their matching definitions, and definition category types
from NiceLocationExpr codeUsage, Definition codeDefinition, string defKind
// Establish connection between usage and definition by verifying they correspond through the definition tracking
where codeDefinition = definitionOf(codeUsage, defKind)
// Return the usage expression, its corresponding definition, and the type of definition relationship
select codeUsage, codeDefinition, defKind