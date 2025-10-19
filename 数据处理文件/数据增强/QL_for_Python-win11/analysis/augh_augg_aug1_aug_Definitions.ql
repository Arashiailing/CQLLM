/**
 * @name Navigate to Definitions
 * @description Advanced navigation utility that identifies relationships between code expressions and their source definitions in Python projects.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import essential Python analysis modules for comprehensive source code examination
import python

// Import definition tracking mechanisms to establish connections between variable references and their declarations
import analysis.DefinitionTracking

// Select source expressions with detailed location information, their corresponding definitions, and definition categories
from NiceLocationExpr sourceExpr, Definition correspondingDef, string defCategory
// Establish precise mapping between expression usage and its definition with type compatibility verification
where 
  correspondingDef = definitionOf(sourceExpr, defCategory)
// Generate output containing source expression location, target definition location, and definition classification
select sourceExpr, correspondingDef, defCategory