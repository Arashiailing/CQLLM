/**
 * @name Module imports itself
 * @description Detects when a module imports itself, which is redundant code
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
 * Determines if a module performs self-import.
 * @param importingStmt - The import statement being analyzed
 * @param targetModule - The module being imported
 * @returns True when the importing module and imported module are identical
 */
predicate is_self_import(ImportingStmt importingStmt, ModuleValue targetModule) {
  // Verify the importing module matches the imported module's scope
  importingStmt.getEnclosingModule() = targetModule.getScope() and
  // Resolve the actual module from the imported name using length-based prioritization
  targetModule =
    max(string importedName, ModuleValue candidate |
      importedName = importingStmt.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// Identify all instances of modules importing themselves
from ImportingStmt importingStmt, ModuleValue targetModule
where is_self_import(importingStmt, targetModule)
select importingStmt, "The module '" + targetModule.getName() + "' imports itself."