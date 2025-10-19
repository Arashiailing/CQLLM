/**
 * @name Navigate to Definitions
 * @description Sophisticated code navigation utility for Python that creates accurate connections
 *              between symbol references and their corresponding declarations. Facilitates precise
 *              tracking of variables, functions, and classes with robust type verification.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Fundamental Python language module for AST representation and structural code examination
import python

// Symbol mapping infrastructure for correlating identifiers with their declarations throughout different scopes
import analysis.DefinitionTracking

// Query elements: symbol reference point, corresponding declaration, and symbol categorization
from NiceLocationExpr symbolUsage, Definition resolvedDefinition, string symbolCategory
where 
  // Establish semantic connection by resolving symbol reference to its declaration
  resolvedDefinition = definitionOf(symbolUsage, symbolCategory)
  // Ensure declaration validity and accessibility within current scope
  and exists(resolvedDefinition.getLocation())
// Result set: reference location, resolved declaration location, and symbol classification
select symbolUsage, resolvedDefinition, symbolCategory