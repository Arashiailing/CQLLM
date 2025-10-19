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
 * Identifies modules that perform self-import operations
 * 
 * This predicate detects scenarios where a Python module imports itself, either directly
 * or indirectly. Self-imports represent unnecessary code patterns that can introduce
 * circular dependencies and create maintenance difficulties in the codebase.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module value object that is being imported
 */
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify the enclosing module of the import statement
  // matches the scope of the imported module
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Use aggregation to identify the most appropriate module value
  // Prioritize longest matching names to handle relative imports correctly
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      // Get the module name referenced in the import statement
      importedName = importStmt.getAnImportedModuleName() and
      // Confirm the candidate module is imported with this name
      candidateModule.importedAs(importedName)
    |
      // Sort by module name length descending to ensure longest match wins
      candidateModule order by importedName.length() desc
    )
}

// Main query: Detect all instances of self-importing modules
// 
// This query examines all import statements and applies the selfImportDetected predicate
// to identify those that satisfy the self-import criteria, generating appropriate
// warning messages for each detected instance.
from ImportingStmt importStmt, ModuleValue importedModule
where selfImportDetected(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."