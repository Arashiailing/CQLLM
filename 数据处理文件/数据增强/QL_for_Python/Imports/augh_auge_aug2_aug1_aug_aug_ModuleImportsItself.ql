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
 * Detects when a module imports itself through any import mechanism
 * 
 * This predicate identifies cases where a Python module performs a self-import operation,
 * which can lead to circular dependencies and unnecessary complexity. Self-imports are
 * considered anti-patterns as they don't provide any functional benefit while potentially
 * causing maintenance issues.
 * 
 * Parameters:
 * - importStmt: The import statement that performs the self-import
 * - importedModule: The module value representing the imported module
 */
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify that the module containing the import statement is the same as the module being imported
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Find the most appropriate module value by prioritizing longer module names
  // This approach ensures correct handling of relative imports by matching the longest possible name
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      // Extract the module name from the import statement
      importedName = importStmt.getAnImportedModuleName() and
      // Ensure the candidate module matches the imported name
      candidateModule.importedAs(importedName)
    |
      // Order by name length descending to prioritize longest matches
      candidateModule order by importedName.length() desc
    )
}

// Query execution: Find all instances where modules import themselves
// 
// This query analyzes import statements across the codebase to detect self-import patterns.
// Each identified instance is reported with a descriptive message indicating which module
// is performing the self-import operation.
from ImportingStmt importStmt, ModuleValue importedModule
where isSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."