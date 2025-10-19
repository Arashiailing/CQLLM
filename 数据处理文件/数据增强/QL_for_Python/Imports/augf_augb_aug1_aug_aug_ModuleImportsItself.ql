/**
 * @name Module imports itself
 * @description Detects modules that import themselves directly
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
 * Identifies direct self-import scenarios where a module imports itself.
 * 
 * This predicate checks for Python modules that import themselves, which typically
 * indicates unnecessary code patterns that may cause circular dependencies and
 * maintenance challenges.
 * 
 * Parameters:
 * - impStmt: The import statement under analysis
 * - targetModule: The module being imported (which matches the importing module)
 */
predicate isSelfImport(ImportingStmt impStmt, ModuleValue targetModule) {
  // Core condition: Ensure importing module matches imported module's scope
  impStmt.getEnclosingModule() = targetModule.getScope() and
  // Resolve module reference using longest-match prioritization
  // Handles relative imports by selecting most specific module match
  targetModule = 
    max(string modName, ModuleValue candidateMod |
      // Extract module name from import statement
      modName = impStmt.getAnImportedModuleName() and
      // Verify candidate module matches imported name
      candidateMod.importedAs(modName)
    |
      // Prioritize longest module names for precise matching
      candidateMod order by modName.length() desc
    )
}

// Main query: Detect all self-importing module instances
// 
// Scans all import statements and uses isSelfImport predicate
// to identify cases where modules import themselves, generating warnings
from ImportingStmt impStmt, ModuleValue targetModule
where isSelfImport(impStmt, targetModule)
select impStmt, "The module '" + targetModule.getName() + "' imports itself."