/**
 * @name Module imports itself
 * @description Identifies modules that perform self-import operations, which typically indicates redundant code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Predicate to detect modules importing themselves
predicate isSelfImportingModule(ImportingStmt importStmt, ModuleValue targetModule) {
  // Verify the importing module matches the imported module's scope
  importStmt.getEnclosingModule() = targetModule.getScope() and
  // Resolve the actual module from the imported name using shortest match
  targetModule =
    max(string modName, ModuleValue resolvedMod |
      modName = importStmt.getAnImportedModuleName() and
      resolvedMod.importedAs(modName)
    |
      resolvedMod order by modName.length()
    )
}

// Query to locate all self-importing module instances
from ImportingStmt importStmt, ModuleValue targetModule
where isSelfImportingModule(importStmt, targetModule)
select importStmt, "The module '" + targetModule.getName() + "' imports itself."