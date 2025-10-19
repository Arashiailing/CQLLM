/**
 * @name Code Definition Navigator
 * @description Enhanced helper query to trace from code usage points to their corresponding definition locations in Python source code.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import the core Python analysis library for examining Python source code structure
import python

// Import the definition tracking functionality to establish relationships between code usage and its definitions
import analysis.DefinitionTracking

// Query to identify expressions with clear location information and map them to their definitions
from NiceLocationExpr codeUsage, Definition codeDefinition, string definitionCategory
// Ensure that the selected definition correctly corresponds to the usage point and that the definition categories are properly aligned
where codeDefinition = definitionOf(codeUsage, definitionCategory)
// Output the usage location, associated definition location, and the category of definition
select codeUsage, codeDefinition, definitionCategory