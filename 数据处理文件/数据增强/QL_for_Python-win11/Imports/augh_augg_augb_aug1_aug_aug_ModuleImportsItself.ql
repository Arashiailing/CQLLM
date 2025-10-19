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
 * Identifies modules that directly import themselves
 * 
 * This predicate detects Python modules that import themselves, which is typically
 * an unnecessary code pattern that can lead to circular dependencies and maintenance issues.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module being imported
 */
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // Check if the importing module's scope matches the imported module's scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Find the most specific module match using longest-name priority
  importedModule = 
    max(string importedName, ModuleValue moduleCandidate |
      // Get the module name referenced in the import statement
      importedName = importStmt.getAnImportedModuleName() and
      // Verify the candidate module is imported under this name
      moduleCandidate.importedAs(importedName)
    |
      // Prioritize longest matching names for correct relative import handling
      moduleCandidate order by importedName.length() desc
    )
}

// Main query: Identify all self-importing module instances
// 
// This query scans all import statements and uses the isSelfImport predicate
// to filter statements where a module imports itself, generating warnings.
from ImportingStmt importStmt, ModuleValue importedModule
where isSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."