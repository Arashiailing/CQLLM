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

// Associates wildcard import statements with their corresponding source modules
predicate associatesWildcardImportWithModule(ImportStar starImport, ModuleValue sourceModule) {
  // Ensures the imported module name matches the source module's identifier
  sourceModule.importedAs(starImport.getImportedModuleName())
}

// Checks if a module explicitly restricts its exports using the '__all__' attribute
predicate moduleRestrictsExports(ModuleValue sourceModule) {
  // Built-in modules are considered to have controlled exports
  sourceModule.isBuiltin()
  or
  // Verifies if '__all__' is defined in the module's import-time scope
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Checks for '__all__' definition in package initialization files
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Identifies wildcard imports that pollute the namespace
from ImportStar starImport, ModuleValue sourceModule
where 
  // Establishes connection between import statement and source module
  associatesWildcardImportWithModule(starImport, sourceModule)
  // Filters out modules that explicitly restrict their exports
  and not moduleRestrictsExports(sourceModule)
  // Excludes modules that cannot be resolved
  and not sourceModule.isAbsent()
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()