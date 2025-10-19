/**
 * @name Navigate to Definitions
 * @description Advanced navigation query that maps Python expression usages to their corresponding definition points,
 *              enabling precise code traversal and analysis of variable, function, and class relationships.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python static analysis capabilities for source code examination
import python

// Import definition tracking functionality to establish connections between usages and their origin points
import analysis.DefinitionTracking

// Select source expressions with precise location data, their corresponding target definitions, and definition categories
from NiceLocationExpr sourceExpr, Definition targetDefinition, string definitionType
// Establish the relationship between usage and definition while ensuring type compatibility
where 
  targetDefinition = definitionOf(sourceExpr, definitionType)
// Generate output containing usage location, definition location, and definition classification for navigation
select sourceExpr, targetDefinition, definitionType