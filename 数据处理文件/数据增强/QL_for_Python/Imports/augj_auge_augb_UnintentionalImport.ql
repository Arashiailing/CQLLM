/**
 * @name Namespace pollution from wildcard imports
 * @description Detects wildcard imports that may pollute the namespace when 
 *              the imported module lacks explicit export definitions
 * @kind problem
 * @tags maintainability
 *       modularity
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/polluting-import
 */

import python

// Establishes connection between star import statements and their source modules
predicate relatesStarImportToModule(ImportStar starImport, ModuleValue sourceModule) {
  // Verifies the imported module name corresponds to the source module identifier
  sourceModule.importedAs(starImport.getImportedModuleName())
}

// Checks if a module implements explicit export controls
predicate hasExportRestrictions(ModuleValue sourceModule) {
  // Built-in modules inherently control their exports
  sourceModule.isBuiltin()
  or
  // Confirms '__all__' is defined in the module's import-time scope
  sourceModule.getScope().(ImportTimeScope).definesName("__all__")
  or
  // Validates '__all__' presence in package initialization files
  sourceModule.getScope().getInitModule().(ImportTimeScope).definesName("__all__")
}

// Identifies problematic wildcard imports lacking export controls
from ImportStar starImport, ModuleValue sourceModule
where 
  // Filters out modules that cannot be resolved
  not sourceModule.isAbsent()
  // Links import statement to its originating module
  and relatesStarImportToModule(starImport, sourceModule)
  // Excludes modules with explicit export restrictions
  and not hasExportRestrictions(sourceModule)
select starImport,
  "Import pollutes the enclosing namespace, as the imported module $@ does not define '__all__'.",
  sourceModule, sourceModule.getName()