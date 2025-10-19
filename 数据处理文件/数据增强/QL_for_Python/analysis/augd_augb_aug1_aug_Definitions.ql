/**
 * @name Definition Navigator
 * @description A utility query that provides navigation capabilities from code references 
 *              to their corresponding source definitions within Python codebases.
 * @kind definitions
 * @id py/definition-navigator
 */

// Import the core Python analysis library for examining Python source code structures
import python

// Import the definition tracking module to enable tracing of variables, functions, and class declarations
import analysis.DefinitionTracking

// Extract code references with location information, their associated definitions, 
// and the classification of those definitions
from NiceLocationExpr codeReference, 
     Definition sourceDefinition, 
     string definitionCategory
// Ensure that the definition correctly corresponds to the reference and maintains type consistency
where sourceDefinition = definitionOf(codeReference, definitionCategory)
// Display the reference location, definition location, and definition category to support navigation
select codeReference, sourceDefinition, definitionCategory