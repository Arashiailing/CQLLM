/**
 * @name Module imports itself
 * @description Detects modules that perform self-import operations
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
predicate isSelfImporting(ImportingStmt importStmt, ModuleValue moduleVal) {
  // Verify the importing module's context matches the imported module's scope
  importStmt.getEnclosingModule() = moduleVal.getScope() and
  // Resolve the most specific module reference using longest-name matching
  // This approach ensures proper handling of relative import paths
  moduleVal = 
    max(string importedName, ModuleValue candidateModule |
      importedName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importedName)
    |
      candidateModule order by importedName.length()
    )
}

// Query to locate all instances of self-importing modules
from ImportingStmt importStmt, ModuleValue moduleVal
where isSelfImporting(importStmt, moduleVal)
select importStmt, "The module '" + moduleVal.getName() + "' imports itself."