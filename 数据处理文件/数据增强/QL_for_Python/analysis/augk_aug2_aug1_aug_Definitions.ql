/**
 * @name Navigate to Definitions
 * @description Helper query for navigating from expression usage to their corresponding definition locations in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python library for static analysis
import python

// Import the definition tracking module for tracing variable, function, and class definitions
import analysis.DefinitionTracking

// Select expressions with precise locations, their associated definitions, and definition categories
from NiceLocationExpr expr, Definition def, string defType
// Ensure the definition correctly corresponds to the usage with compatible types
where def = definitionOf(expr, defType)
// Output the usage location, definition location, and definition type for navigation
select expr, def, defType