/**
 * @name Navigate to Definitions
 * @description Advanced navigation utility that establishes connections between Python expressions 
 *              and their corresponding source definitions, facilitating efficient code tracing 
 *              and comprehension for developers.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import fundamental Python analysis framework for comprehensive static code inspection
import python

// Integrate definition tracking functionality to precisely trace origins of variables, functions, and classes
import analysis.DefinitionTracking

// Identify expressions with location metadata, their corresponding source definitions, and classification categories
from NiceLocationExpr sourceRef, Definition sourceDef, string defCategory
where 
  // Link expression to its source definition
  sourceDef = definitionOf(sourceRef, defCategory)
  // Ensure both expression and definition have valid location data
  and exists(sourceRef.getLocation()) 
  and exists(sourceDef.getLocation())
// Output reference expression location, source definition location, and definition classification
select sourceRef, sourceDef, defCategory