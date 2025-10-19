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
 * Detects when a module imports itself.
 * This predicate identifies self-importing modules by comparing the context module
 * of an import statement with the module being imported.
 */
predicate isSelfImporting(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify that the enclosing module of the import statement matches the scope
  // of the module being imported
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Use aggregation to select the most appropriate module reference
  // Prefer matches with longer names to correctly handle relative imports
  importedModule = 
    max(string importName, ModuleValue candidateModule |
      importName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importName)
    |
      candidateModule order by importName.length()
    )
}

// Query to find all instances of modules that import themselves
from ImportingStmt importStmt, ModuleValue targetModule
where isSelfImporting(importStmt, targetModule)
select importStmt, "The module '" + targetModule.getName() + "' imports itself."