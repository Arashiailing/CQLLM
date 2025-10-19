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
 * - importDeclaration: The import statement being analyzed
 * - targetModule: The module value object that is being imported
 */
predicate selfImportDetected(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // Core verification: ensure the enclosing module of the import statement
  // corresponds to the scope of the imported module
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // Utilize aggregation to identify the most appropriate module value
  // Prioritize longest matching names to properly handle relative imports
  targetModule = 
    max(string moduleName, ModuleValue potentialModule |
      // Obtain the module name referenced in the import statement
      moduleName = importDeclaration.getAnImportedModuleName() and
      // Confirm that the candidate module is imported with this name
      potentialModule.importedAs(moduleName)
    |
      // Sort by module name length in descending order to ensure longest match takes precedence
      potentialModule order by moduleName.length() desc
    )
}

// Primary query: Detect all instances of self-importing modules
// 
// This query examines all import statements and applies the selfImportDetected predicate
// to identify those that satisfy the self-import criteria, generating appropriate
// warning messages for each detected instance.
from ImportingStmt importDeclaration, ModuleValue targetModule
where selfImportDetected(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."