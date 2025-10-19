/**
 * @name 'import *' may pollute namespace
 * @description Importing a module using 'import *' may unintentionally pollute the global
 *              namespace if the module does not define `__all__`
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

// Associates wildcard import statements with their source modules
predicate linksStarImportToModule(ImportStar wildcardImport, ModuleValue importedModule) {
  // Ensures the imported module name matches the source module's identifier
  importedModule.importedAs(wildcardImport.getImportedModuleName())
}

// Determines if a module restricts exports via '__all__' attribute
predicate restrictsExports(ModuleValue importedModule) {
  // Built-in modules are considered to have controlled exports
  importedModule.isBuiltin()
  or
  // Checks if '__all__' is defined in the module's import-time scope
  importedModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Verifies '__all__' definition in package initialization files
  importedModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Identifies namespace-polluting wildcard imports
from ImportStar wildcardImport, ModuleValue importedModule
where 
  // Establishes relationship between import statement and source module
  linksStarImportToModule(wildcardImport, importedModule)
  // Excludes modules that explicitly define export restrictions
  and not restrictsExports(importedModule)
  // Filters out modules that cannot be resolved
  and not importedModule.isAbsent()
select wildcardImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  importedModule, importedModule.getName()