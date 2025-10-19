/**
 * @name Definitions
 * @description Jump to definition helper query that identifies the definitions
 *              corresponding to various expression usages in Python code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import Python library for analyzing Python source code
import python

// Import DefinitionTracking module to trace variable and function definitions
import analysis.DefinitionTracking

// Select expression usages, their corresponding definitions, and definition types
from NiceLocationExpr exprUsage, Definition targetDefinition, string definitionType
// Condition: the target definition matches the expression usage for the given definition type
where targetDefinition = definitionOf(exprUsage, definitionType)
// Output the expression usage location, its definition location, and the definition type
select exprUsage, targetDefinition, definitionType