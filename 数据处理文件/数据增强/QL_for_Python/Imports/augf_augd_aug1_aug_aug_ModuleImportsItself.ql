/**
 * @name Module imports itself
 * @description Detects when a module imports itself, creating circular dependencies
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
 * This predicate finds self-import scenarios where a module references itself,
 * which typically indicates problematic code patterns that can lead to circular
 * dependencies and maintenance difficulties.
 * 
 * Parameters:
 * - importDeclaration: The import statement being analyzed
 * - targetModule: The module value being imported
 */
predicate selfImportDetected(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // Core condition: verify that the importing module's scope matches the imported module's scope
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  
  // Resolve the most appropriate module value using name length prioritization
  // Longer module names take precedence to correctly handle relative imports
  targetModule = 
    max(string importName, ModuleValue potentialModule |
      // Extract the module name referenced in the import statement
      importName = importDeclaration.getAnImportedModuleName() and
      // Verify the candidate module matches the imported name
      potentialModule.importedAs(importName)
    |
      // Prioritize longer module names for precise matching
      potentialModule order by importName.length() desc
    )
}

// Main query: Identify all self-import module instances
// 
// This query analyzes all import statements, filtering for those that
// meet self-import conditions through the selfImportDetected predicate,
// and generates corresponding warning messages.
from ImportingStmt importDeclaration, ModuleValue targetModule
where selfImportDetected(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."