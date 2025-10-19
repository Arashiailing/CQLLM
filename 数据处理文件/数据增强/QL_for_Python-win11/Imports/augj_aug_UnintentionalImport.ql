/**
 * @name 'import *' may pollute namespace
 * @description Identifies wildcard imports that risk namespace pollution
 *              when the source module doesn't specify '__all__' exports
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

// Predicate to determine if a module properly constrains its exports via '__all__'
predicate constrainsExports(ModuleValue importedModule) {
  // Exclude built-in modules as they have controlled exports
  importedModule.isBuiltin()
  or
  // Verify '__all__' is defined in the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Check if '__all__' is defined in the module's initialization section
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Main query to detect problematic wildcard imports
from ImportStar wildcardImport, ModuleValue importedModule
where 
  // Establish relationship between import statement and source module
  importedModule.importedAs(wildcardImport.getImportedModuleName()) and
  // Filter out modules that properly constrain their exports
  not constrainsExports(importedModule) and
  // Exclude modules that cannot be resolved
  not importedModule.isAbsent()
select wildcardImport,
  "Wildcard import pollutes the namespace because module $@ lacks '__all__' definition.",
  importedModule, importedModule.getName()