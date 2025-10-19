/**
 * @name Navigate to Definitions
 * @description Enhanced helper query for navigating from expression usage to their corresponding definition locations in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python library for static analysis of Python source code
import python

// Import the definition tracking module to enable tracing of variable, function, and class definitions
import analysis.DefinitionTracking

// Select expressions with precise locations, their associated definitions, and the category of each definition
from NiceLocationExpr refExpr, Definition targetDef, string defKind
// Ensure that the definition correctly corresponds to the usage and that their types are compatible
where 
  targetDef = definitionOf(refExpr, defKind)
// Output the usage location, definition location, and definition type for navigation purposes
select refExpr, targetDef, defKind