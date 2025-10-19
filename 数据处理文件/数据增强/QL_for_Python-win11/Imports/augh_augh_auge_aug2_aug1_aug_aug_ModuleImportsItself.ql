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
 * Identifies self-import scenarios where a module imports its own code
 * 
 * This predicate detects circular import patterns where a module attempts to import itself.
 * Such imports are anti-patterns that introduce unnecessary complexity and potential circular
 * dependencies without providing functional benefits. The analysis handles both absolute and
 * relative imports by matching the longest possible module name.
 * 
 * Parameters:
 * - selfImportStmt: The import statement performing the self-import
 * - targetModule: The module value representing the imported module
 */
predicate isSelfImport(ImportingStmt selfImportStmt, ModuleValue targetModule) {
  // Verify the containing module matches the imported module's scope
  selfImportStmt.getEnclosingModule() = targetModule.getScope() and
  // Resolve module ambiguity by selecting the longest matching module name
  targetModule = 
    max(string moduleName, ModuleValue candidate |
      // Extract imported module name from the statement
      moduleName = selfImportStmt.getAnImportedModuleName() and
      // Ensure candidate module corresponds to the imported name
      candidate.importedAs(moduleName)
    |
      // Prioritize longer module names to handle relative imports correctly
      candidate order by moduleName.length() desc
    )
}

// Detect all self-import instances across the codebase
// 
// This query identifies modules that import themselves through any import mechanism.
// Each finding provides context about the specific import statement and the affected module,
// helping developers eliminate unnecessary circular dependencies.
from ImportingStmt selfImportStmt, ModuleValue targetModule
where isSelfImport(selfImportStmt, targetModule)
select selfImportStmt, "The module '" + targetModule.getName() + "' imports itself."