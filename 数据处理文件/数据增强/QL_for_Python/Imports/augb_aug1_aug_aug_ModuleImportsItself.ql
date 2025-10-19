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
 * Identifies self-importing modules where a module imports itself directly
 * 
 * This predicate detects Python modules that import themselves, which is typically
 * an unnecessary code pattern that can lead to circular dependencies and maintenance issues.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The target module being imported
 */
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // Core condition: verify the importing module matches the imported module's scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Resolve the most specific module match using aggregation
  // Prioritizes longest matching names to handle relative imports correctly
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      // Extract the module name referenced in the import statement
      importedName = importStmt.getAnImportedModuleName() and
      // Verify candidate module is imported under this name
      candidateModule.importedAs(importedName)
    |
      // Sort by module name length descending for longest match priority
      candidateModule order by importedName.length() desc
    )
}

// Main query: Identify all self-importing module instances
// 
// This query scans all import statements and uses the isSelfImport predicate
// to filter statements where a module imports itself, generating warnings.
from ImportingStmt importStmt, ModuleValue importedModule
where isSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."