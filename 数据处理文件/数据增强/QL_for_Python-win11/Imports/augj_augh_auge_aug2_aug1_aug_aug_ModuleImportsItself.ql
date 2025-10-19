/**
 * @name Module imports itself
 * @description Detects when a Python module imports itself through any import mechanism
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
 * Identifies self-import patterns where a module imports itself
 * 
 * This predicate captures instances where a Python module performs a self-import operation.
 * Such patterns are considered anti-patterns as they introduce circular dependencies and
 * unnecessary complexity without providing functional benefits.
 * 
 * Parameters:
 * - selfImportStmt: The import statement performing the self-import
 * - selfImportedModule: The module value representing the imported module
 */
predicate isSelfImport(ImportingStmt selfImportStmt, ModuleValue selfImportedModule) {
  // Verify the importing module matches the imported module's scope
  selfImportStmt.getEnclosingModule() = selfImportedModule.getScope() and
  // Select the most appropriate module value by prioritizing longer module names
  // This ensures correct handling of relative imports through longest-match resolution
  selfImportedModule = 
    max(string moduleName, ModuleValue moduleCandidate |
      moduleName = selfImportStmt.getAnImportedModuleName() and
      moduleCandidate.importedAs(moduleName)
    |
      // Order by module name length descending to prioritize longest matches
      moduleCandidate order by moduleName.length() desc
    )
}

// Query execution: Identify all self-import instances across the codebase
// 
// This analysis examines import statements to detect modules that import themselves.
// Each finding includes the problematic import statement and a descriptive message
// indicating which module is performing the self-import operation.
from ImportingStmt selfImportStmt, ModuleValue selfImportedModule
where isSelfImport(selfImportStmt, selfImportedModule)
select selfImportStmt, "The module '" + selfImportedModule.getName() + "' imports itself."