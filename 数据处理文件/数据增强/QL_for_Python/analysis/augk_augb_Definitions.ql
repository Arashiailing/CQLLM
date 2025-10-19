/**
 * @name Symbol Definitions
 * @description Assists in locating symbol definitions within Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import necessary modules for Python code analysis
import python
import analysis.DefinitionTracking

// Find symbol definitions that correspond to their usages
from NiceLocationExpr symbolUsage, Definition symbolDefinition, string defType
where symbolDefinition = definitionOf(symbolUsage, defType)
// Output the usage location, corresponding definition, and type of definition
select symbolUsage, symbolDefinition, defType