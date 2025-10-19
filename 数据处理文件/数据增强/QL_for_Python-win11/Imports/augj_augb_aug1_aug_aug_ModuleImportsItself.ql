/**
 * @name Module imports itself
 * @description Detects modules that directly import themselves
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
 * Identifies self-importing modules where a module imports itself directly
 * 
 * This predicate detects Python modules that import themselves, which is typically
 * an unnecessary code pattern that can lead to circular dependencies and maintenance issues.
 * 
 * Parameters:
 * - importingStatement: The import statement being analyzed
 * - targetModule: The target module being imported
 */
predicate isSelfImport(ImportingStmt importingStatement, ModuleValue targetModule) {
  // Core condition: verify the importing module matches the imported module's scope
  importingStatement.getEnclosingModule() = targetModule.getScope() and
  // Resolve the most specific module match using aggregation
  // Prioritizes longest matching names to handle relative imports correctly
  targetModule = 
    max(string moduleName, ModuleValue candidate |
      // Extract the module name referenced in the import statement
      moduleName = importingStatement.getAnImportedModuleName() and
      // Verify candidate module is imported under this name
      candidate.importedAs(moduleName)
    |
      // Sort by module name length descending for longest match priority
      candidate order by moduleName.length() desc
    )
}

// Main query: Identify all self-importing module instances
// 
// This query scans all import statements and uses the isSelfImport predicate
// to filter statements where a module imports itself, generating warnings.
from ImportingStmt importingStatement, ModuleValue targetModule
where isSelfImport(importingStatement, targetModule)
select importingStatement, "The module '" + targetModule.getName() + "' imports itself."