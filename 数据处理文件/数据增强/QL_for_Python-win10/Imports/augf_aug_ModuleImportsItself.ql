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

// Predicate to identify modules that perform self-import
predicate isSelfImportingModule(ImportingStmt importStmt, ModuleValue selfModule) {
  // Condition 1: The import statement's enclosing module must match the imported module's scope
  importStmt.getEnclosingModule() = selfModule.getScope() and
  // Condition 2: Resolve the imported module name to its corresponding ModuleValue
  // using the shortest module name to handle potential naming conflicts
  selfModule = max(string moduleName, ModuleValue resolvedModule |
      moduleName = importStmt.getAnImportedModuleName() and
      resolvedModule.importedAs(moduleName)
    | resolvedModule order by moduleName.length()
  )
}

// Query to identify all instances of self-importing modules
from ImportingStmt importStmt, ModuleValue selfModule
where isSelfImportingModule(importStmt, selfModule)
select importStmt, "The module '" + selfModule.getName() + "' imports itself."