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
 * Identifies self-importing modules by comparing importing and imported modules.
 * The analysis resolves imported module names and selects the shortest match
 * to avoid ambiguous module references.
 */
from ImportingStmt importStmt, ModuleValue importedModule
where 
  // Ensure the importing module's scope matches the imported module's scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Resolve the imported module name and find the shortest matching module
  exists(string importedName |
    importedName = importStmt.getAnImportedModuleName() and
    importedModule = min(ModuleValue candidate |
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
  )
select importStmt, "The module '" + importedModule.getName() + "' imports itself."