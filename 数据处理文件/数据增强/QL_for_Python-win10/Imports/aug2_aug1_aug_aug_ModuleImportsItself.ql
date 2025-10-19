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
 * Identifies modules that import themselves
 * 
 * This predicate detects self-import scenarios in Python modules, where a module
 * directly or indirectly imports itself. Self-imports are typically unnecessary
 * code patterns that can lead to circular dependencies and maintenance challenges.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module value object being imported
 */
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  // Core condition: verify the enclosing module of the import statement
  // matches the scope of the imported module
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Use aggregation to find the best matching module value
  // Prioritize longest matching names to handle relative imports correctly
  importedModule = 
    max(string modName, ModuleValue candidateModule |
      // Retrieve the module name referenced in the import statement
      modName = importStmt.getAnImportedModuleName() and
      // Check if the candidate module is imported with this name
      candidateModule.importedAs(modName)
    |
      // Sort by module name length in descending order to ensure longest match wins
      candidateModule order by modName.length() desc
    )
}

// Main query: Identify all instances of self-importing modules
// 
// This query examines all import statements and filters those that meet
// the self-import criteria using the selfImportDetected predicate,
// generating appropriate warning messages.
from ImportingStmt importStmt, ModuleValue importedModule
where selfImportDetected(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."