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
 * - importDeclaration: The import statement being analyzed
 * - targetModule: The module being imported
 */
predicate isSelfImport(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // Verify the importing module matches the imported module's scope
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // Resolve the most specific module match using longest-name priority
  targetModule = 
    max(string moduleName, ModuleValue candidate |
      // Extract module name referenced in the import statement
      moduleName = importDeclaration.getAnImportedModuleName() and
      // Verify candidate module is imported under this name
      candidate.importedAs(moduleName)
    |
      // Prioritize longest matching names for correct relative import handling
      candidate order by moduleName.length() desc
    )
}

// Main query: Identify all self-importing module instances
// 
// This query scans all import statements and uses the isSelfImport predicate
// to filter statements where a module imports itself, generating warnings.
from ImportingStmt importDeclaration, ModuleValue targetModule
where isSelfImport(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."