/**
 * @name Symbol Definitions
 * @description A utility query that maps symbol usages to their corresponding definitions in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the Python analysis module for source code examination
import python

// Import the DefinitionTracking module to trace variable and function declarations
import analysis.DefinitionTracking

// This query identifies definitions that correspond to specific symbol usages
from NiceLocationExpr symbolUsage, Definition correspondingDefinition, string defType
// Establish the relationship between a symbol usage and its definition
where correspondingDefinition = definitionOf(symbolUsage, defType)
// Output the usage location, associated definition, and type of definition
select symbolUsage, correspondingDefinition, defType