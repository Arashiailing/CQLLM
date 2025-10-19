/**
 * @name Module imports itself
 * @description Identifies modules that perform self-import operations
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

/**
 * Detects modules importing themselves by comparing import context with target module.
 * The predicate verifies that the enclosing module of the import statement matches
 * the scope of the imported module, using name-length prioritization for resolution.
 */
predicate isSelfImporting(ImportingStmt importStatement, ModuleValue targetMod) {
  // Confirm the import statement's enclosing module matches the target module's scope
  importStatement.getEnclosingModule() = targetMod.getScope() and
  // Resolve module reference prioritizing longer names for relative import handling
  targetMod = 
    max(string importedName, ModuleValue candidateMod |
      importedName = importStatement.getAnImportedModuleName() and
      candidateMod.importedAs(importedName)
    |
      candidateMod order by importedName.length()
    )
}

// Query to identify all modules performing self-import operations
from ImportingStmt importStatement, ModuleValue targetMod
where isSelfImporting(importStatement, targetMod)
select importStatement, "The module '" + targetMod.getName() + "' imports itself."