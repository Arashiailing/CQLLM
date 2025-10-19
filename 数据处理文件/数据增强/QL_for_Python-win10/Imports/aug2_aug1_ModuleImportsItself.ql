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
 * Determines if a module imports itself.
 * @param importingStmt - The import statement being analyzed
 * @param targetModule - The module being imported
 * @returns true if the enclosing module of the import statement matches the imported module
 */
predicate moduleImportsItself(ImportingStmt importingStmt, ModuleValue targetModule) {
  // Verify the enclosing module matches the imported module's scope
  importingStmt.getEnclosingModule() = targetModule.getScope() and
  // Identify the actual imported module from the import statement
  targetModule =
    max(string importedName, ModuleValue candidate |
      importedName = importingStmt.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// Identify all instances where a module imports itself
from ImportingStmt importingStmt, ModuleValue importedModule
where moduleImportsItself(importingStmt, importedModule)
select importingStmt, "The module '" + importedModule.getName() + "' imports itself."