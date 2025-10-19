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
 * Identifies self-importing modules by comparing import contexts
 * 
 * This predicate finds Python modules that import themselves, which typically
 * indicates unnecessary code patterns that may cause circular dependencies.
 * 
 * Parameters:
 * - importDeclaration: The import statement being analyzed
 * - targetModule: The module being imported
 */
predicate isSelfImport(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // Verify the importing context matches the imported module's scope
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // Resolve the most specific module match using longest-name priority
  targetModule = 
    max(string moduleName, ModuleValue candidateMod |
      moduleName = importDeclaration.getAnImportedModuleName() and
      candidateMod.importedAs(moduleName)
    |
      candidateMod order by moduleName.length() desc
    )
}

// Main query: Detect all self-importing module instances
// 
// This query scans all import statements and identifies cases where
// a module imports itself, generating maintainability warnings.
from ImportingStmt importDeclaration, ModuleValue targetModule
where isSelfImport(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."