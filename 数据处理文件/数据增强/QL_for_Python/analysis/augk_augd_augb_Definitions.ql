/**
 * @name Symbol Definitions
 * @description Identifies and maps symbol references to their corresponding definitions in Python code,
 *              facilitating navigation between usage and declaration sites.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the Python analysis module for comprehensive source code examination
import python

// Import the DefinitionTracking module to trace variable, function, and class declarations
import analysis.DefinitionTracking

// This query establishes relationships between symbol references and their source definitions
from NiceLocationExpr symbolReference, Definition matchingDefinition, string definitionCategory
// Condition to match each symbol reference with its corresponding definition
where 
  // Link the symbol reference to its appropriate definition
  matchingDefinition = definitionOf(symbolReference, definitionCategory)
// Output the symbol reference location, its matching definition, and the definition category
select symbolReference, matchingDefinition, definitionCategory