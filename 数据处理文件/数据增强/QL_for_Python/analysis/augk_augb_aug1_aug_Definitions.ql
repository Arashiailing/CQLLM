/**
 * @name Definition Navigator
 * @description Advanced utility query that facilitates navigation from code references to their corresponding source definitions 
 *              within Python projects. This query provides a comprehensive mapping between usage sites and their declarations,
 *              enabling efficient code comprehension and refactoring workflows.
 * @kind definitions
 * @id py/definition-navigator
 */

// Import the core Python analysis library for comprehensive examination of Python source code structures
import python

// Import the definition tracking module to enable precise tracing of variable declarations, function definitions,
// and class declarations throughout the codebase
import analysis.DefinitionTracking

// Identify expression references along with their associated target definitions and classification types
from NiceLocationExpr expressionRef, Definition targetDefinition, string definitionType
// Establish the relationship between expression references and their corresponding source definitions,
// ensuring proper type compatibility and semantic consistency
where targetDefinition = definitionOf(expressionRef, definitionType)
// Output the expression reference, its corresponding definition, and the definition type classification
// to support navigation and analysis workflows
select expressionRef, targetDefinition, definitionType