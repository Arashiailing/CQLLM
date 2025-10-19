/**
 * @name Navigate to Definitions
 * @description Enhanced navigation helper for tracing expressions to their source definitions in Python code
 * @kind definitions
 * @id py/jump-to-definition
 */

// Core Python static analysis module
import python

// Definition tracking capabilities for resolving variable/function/class origins
import analysis.DefinitionTracking

// Select expressions with precise locations, their resolved definitions, and definition categories
from NiceLocationExpr usageExpr, Definition resolvedDef, string defCategory
// Ensure proper definition resolution with type compatibility between usage and definition
where 
  resolvedDef = definitionOf(usageExpr, defCategory)
// Output navigation triplet: usage location, definition location, and definition type
select usageExpr, resolvedDef, defCategory