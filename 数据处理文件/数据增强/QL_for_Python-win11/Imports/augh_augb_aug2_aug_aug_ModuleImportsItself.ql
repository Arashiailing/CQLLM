/**
 * @name Module imports itself
 * @description A module imports itself
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
 * Identifies modules that perform self-import operations.
 * This predicate detects when a module references itself through import statements
 * by comparing the importing module's context with the imported module's scope.
 */
predicate isSelfImporting(ImportingStmt impStmt, ModuleValue modVal) {
  // Confirm the importing module's context matches the imported module's scope
  impStmt.getEnclosingModule() = modVal.getScope() and
  // Resolve the most specific module reference using longest-name matching
  // This approach ensures proper handling of relative import paths
  modVal = 
    max(string impName, ModuleValue candidateMod |
      impName = impStmt.getAnImportedModuleName() and
      candidateMod.importedAs(impName)
    |
      candidateMod order by impName.length()
    )
}

// Query to locate all instances of self-importing modules
from ImportingStmt impStmt, ModuleValue modVal
where isSelfImporting(impStmt, modVal)
select impStmt, "The module '" + modVal.getName() + "' imports itself."