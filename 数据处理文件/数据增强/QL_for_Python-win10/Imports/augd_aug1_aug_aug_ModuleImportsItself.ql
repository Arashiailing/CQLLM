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
 * Identifies modules that import themselves directly or indirectly
 * 
 * This predicate detects self-import scenarios where a module references itself,
 * which typically indicates unnecessary code patterns that can lead to circular
 * dependencies and maintenance challenges.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module value being imported
 */
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  // Validate that the importing module's scope matches the imported module's scope
  // This is the core condition for detecting self-imports
  importStmt.getEnclosingModule() = importedModule.getScope() and
  
  // Resolve the most appropriate module value using name length prioritization
  // Longer module names take precedence to correctly handle relative imports
  importedModule = 
    max(string moduleName, ModuleValue candidateModule |
      // Extract the module name referenced in the import statement
      moduleName = importStmt.getAnImportedModuleName() and
      // Verify the candidate module matches the imported name
      candidateModule.importedAs(moduleName)
    |
      // Prioritize longer module names for precise matching
      candidateModule order by moduleName.length() desc
    )
}

// Main query: Identify all self-import module instances
// 
// This query examines all import statements, filtering for those that
// satisfy self-import conditions through the selfImportDetected predicate,
// and generates corresponding warning messages.
from ImportingStmt importStmt, ModuleValue importedModule
where selfImportDetected(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."