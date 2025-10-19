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
 * Identifies modules that perform self-import operations.
 * This predicate detects when a module references itself through import statements
 * by comparing the importing module's context with the imported module's scope.
 */
predicate isSelfImporting(ImportingStmt importDeclaration, ModuleValue importedModule) {
  // Verify that the module containing the import statement is the same as the module being imported
  importDeclaration.getEnclosingModule() = importedModule.getScope() and
  // Resolve the most specific module reference using longest-name matching
  // This approach ensures proper handling of relative import paths
  importedModule = 
    max(string moduleName, ModuleValue potentialModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      potentialModule.importedAs(moduleName)
    |
      potentialModule order by moduleName.length()
    )
}

// Query to locate all instances of self-importing modules
from ImportingStmt importDeclaration, ModuleValue importedModule
where isSelfImporting(importDeclaration, importedModule)
select importDeclaration, "The module '" + importedModule.getName() + "' imports itself."