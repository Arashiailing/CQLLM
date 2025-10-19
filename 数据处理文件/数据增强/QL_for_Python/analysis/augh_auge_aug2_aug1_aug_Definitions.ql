/**
 * @name Navigate to Definitions
 * @description Advanced navigation tool for Python code analysis that establishes precise mappings
 *              between symbol usage sites and their declaration points. Enables accurate tracing
 *              of variables, functions, and classes with comprehensive type validation.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Core Python language support module providing AST representation and code structure analysis
import python

// Symbol resolution framework for mapping identifiers to their declarations across scopes
import analysis.DefinitionTracking

// Query components: usage location expression, target definition, and symbol classification
from NiceLocationExpr usageSite, Definition targetDefinition, string symbolType
// Resolution logic establishing semantic linkage between usage and definition
where 
  // Perform symbol resolution to connect usage with corresponding declaration
  targetDefinition = definitionOf(usageSite, symbolType) and
  // Ensure the definition is valid and accessible in the current scope
  exists(targetDefinition.getLocation())
// Result set: usage location, resolved definition location, and symbol type classification
select usageSite, targetDefinition, symbolType