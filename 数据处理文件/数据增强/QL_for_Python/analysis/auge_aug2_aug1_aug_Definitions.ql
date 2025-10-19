/**
 * @name Navigate to Definitions
 * @description Enhanced navigation assistant for Python source code that traces relationships between 
 *              expression usage sites and their corresponding definition locations. Provides precise 
 *              mapping for variables, functions, and classes with semantic type verification.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Core Python analysis module for static code representation and AST traversal
import python

// Definition tracking module enabling semantic resolution of symbols to their declarations
import analysis.DefinitionTracking

// Primary query components: expression usage, its resolved definition, and semantic category
from NiceLocationExpr expressionUsage, Definition correspondingDefinition, string definitionCategory
// Core resolution logic ensuring valid semantic relationships between usage and definition
where 
  // Establish precise definition-to-usage correspondence with type compatibility
  correspondingDefinition = definitionOf(expressionUsage, definitionCategory)
// Output triad: usage location, resolved definition location, and semantic category
select expressionUsage, correspondingDefinition, definitionCategory