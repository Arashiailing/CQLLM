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

// Identifies modules that perform self-import by matching import context with resolved module
predicate isSelfImportingModule(ImportingStmt importStmt, ModuleValue targetModule) {
  // Verify the importing module context matches the imported module's scope
  importStmt.getEnclosingModule() = targetModule.getScope() and
  // Resolve the shortest matching module name to avoid ambiguous imports
  targetModule = 
    max(string importedName, ModuleValue resolvedMod |
      importedName = importStmt.getAnImportedModuleName() and
      resolvedMod.importedAs(importedName)
    | resolvedMod order by importedName.length()
  )
}

// Query to detect all self-importing module instances
from ImportingStmt importStmt, ModuleValue targetModule
where isSelfImportingModule(importStmt, targetModule)
select importStmt, "The module '" + targetModule.getName() + "' imports itself."