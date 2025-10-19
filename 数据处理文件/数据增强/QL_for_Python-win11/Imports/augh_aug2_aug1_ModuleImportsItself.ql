/**
 * @name Module imports itself
 * @description Detects when a module imports itself
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
 * Identifies self-import scenarios where a module imports itself.
 * @param importStatement - The import statement being evaluated
 * @param targetModule - The module being imported
 * @returns true if the importing module matches the imported module
 */
predicate moduleImportsItself(ImportingStmt importStatement, ModuleValue targetModule) {
  // Verify the importing module matches the imported module's scope
  importStatement.getEnclosingModule() = targetModule.getScope() and
  // Resolve the actual imported module from the import statement
  targetModule =
    max(string moduleName, ModuleValue moduleCandidate |
      moduleName = importStatement.getAnImportedModuleName() and
      moduleCandidate.importedAs(moduleName)
    |
      moduleCandidate order by moduleName.length()
    )
}

// Find all import statements where a module imports itself
from ImportingStmt importStatement, ModuleValue importedModule
where moduleImportsItself(importStatement, importedModule)
select importStatement, "The module '" + importedModule.getName() + "' imports itself."