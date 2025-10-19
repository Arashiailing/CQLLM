/**
 * @name Module imports itself
 * @description Detects when a module imports itself, which is typically a code smell
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Predicate to identify self-importing modules
predicate isSelfImportingModule(ImportingStmt importStatement, ModuleValue importedModule) {
  // The enclosing module of the import statement must match the imported module
  importStatement.getEnclosingModule() = importedModule.getScope() and
  // Resolve the imported module name to its corresponding ModuleValue
  importedModule =
    max(string moduleName, ModuleValue resolvedModule |
      moduleName = importStatement.getAnImportedModuleName() and
      resolvedModule.importedAs(moduleName)
    |
      resolvedModule order by moduleName.length()
    )
}

// Query to find all instances of modules that import themselves
from ImportingStmt importStatement, ModuleValue importedModule
where isSelfImportingModule(importStatement, importedModule)
select importStatement, "The module '" + importedModule.getName() + "' imports itself."