/**
 * @name Symbol Definition Resolver
 * @description Advanced navigation query that maps symbol references to their corresponding definitions in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis module for source code parsing and AST construction
import python

// Import specialized DefinitionTracking module for resolving variable, function, and class definition relationships
import analysis.DefinitionTracking

// Enhanced query for resolving symbol references to their definitions
from Definition symbolDefinition, NiceLocationExpr exprLocation, string symbolCategory
// Apply filtering logic to establish the relationship between symbol usage and its definition
where symbolDefinition = definitionOf(exprLocation, symbolCategory)
// Output the symbol usage location, resolved definition, and definition category
select exprLocation, symbolDefinition, symbolCategory