/**
 * @name Module imports itself
 * @description Identifies modules that import themselves through import statements
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
 * Determines if a module performs self-import by resolving imported modules
 * and comparing against the importing module's scope.
 * @param stmt - The import statement under analysis
 * @param importedMod - The resolved module being imported
 * @returns True when the importing module matches the imported module
 */
predicate selfImportingModule(ImportingStmt stmt, ModuleValue importedMod) {
  // Resolve the actual module being imported from the import statement
  importedMod =
    max(string moduleName, ModuleValue candidate |
      moduleName = stmt.getAnImportedModuleName() and
      candidate.importedAs(moduleName)
    |
      candidate order by moduleName.length()
    ) and
  // Verify the importing module scope matches the imported module scope
  stmt.getEnclosingModule() = importedMod.getScope()
}

// Detect all instances where modules import themselves
from ImportingStmt stmt, ModuleValue importedMod
where selfImportingModule(stmt, importedMod)
select stmt, "The module '" + importedMod.getName() + "' imports itself."