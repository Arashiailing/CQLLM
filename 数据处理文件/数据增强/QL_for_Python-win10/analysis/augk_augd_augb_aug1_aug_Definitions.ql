/**
 * @name Source Definition Locator
 * @description A navigation utility that maps code references to their 
 *              corresponding source definitions within Python codebases.
 * @kind definitions
 * @id py/source-definition-locator
 */

// Core Python analysis library for examining Python source code structures
import python

// Definition tracking module to enable tracing of variables, functions, and class declarations
import analysis.DefinitionTracking

// Identify code references with location information, their associated definitions,
// and the classification of those definitions
from NiceLocationExpr refLocation, 
     Definition defTarget, 
     string defType
// Establish the relationship between references and their corresponding definitions
// ensuring type consistency is maintained
where defTarget = definitionOf(refLocation, defType)
// Display the reference location, definition location, and definition type to support navigation
select refLocation, defTarget, defType