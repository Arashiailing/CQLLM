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
 * Identifies when a module performs a self-import operation.
 * 
 * This predicate detects cases where a Python module imports itself, either directly
 * or indirectly. Self-imports are generally unnecessary code patterns that can lead
 * to circular dependencies and maintenance challenges.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module value that is being imported
 */
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify that the module containing the import statement
  // matches the scope of the module being imported
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Determine the most appropriate module value through aggregation
  // Prioritize the longest matching name to correctly handle relative imports
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      // Extract the module name referenced in the import statement
      importedName = importStmt.getAnImportedModuleName() and
      // Check if the candidate module is imported under this name
      candidateModule.importedAs(importedName)
    |
      // Sort by module name length in descending order to ensure longest match takes precedence
      candidateModule order by importedName.length() desc
    )
}

// Main query: Identify all instances of self-importing modules
// 
// This query examines all import statements and uses the selfImportDetected predicate
// to filter those that meet the self-import condition, generating appropriate warnings.
from ImportingStmt importStmt, ModuleValue importedModule
where selfImportDetected(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."