/**
 * @name 'import *' may pollute namespace
 * @description Identifies wildcard imports that risk namespace pollution
 *              by importing modules without explicit '__all__' definitions
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

// Import Python analysis framework for AST traversal and module inspection
import python

// Predicate that establishes relationship between wildcard imports and their source modules
predicate relatesToImportedModule(ImportStar wildcardImport, ModuleValue importedModule) {
  // Confirm the module's name corresponds to the imported identifier
  importedModule.importedAs(wildcardImport.getImportedModuleName())
}

// Predicate that determines if a module has proper '__all__' export definitions
predicate definesExplicitExports(ModuleValue importedModule) {
  // Built-in modules are exempt as they have controlled namespaces
  importedModule.isBuiltin()
  or
  // Verify '__all__' is defined within the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Also check module initialization for '__all__' definition
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Main query logic to detect namespace-polluting wildcard imports
from ImportStar wildcardImport, ModuleValue importedModule
where 
  relatesToImportedModule(wildcardImport, importedModule) and
  not definesExplicitExports(importedModule) and
  not importedModule.isAbsent()
select wildcardImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()