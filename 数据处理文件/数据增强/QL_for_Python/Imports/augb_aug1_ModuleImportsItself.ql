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
 * @param importStatement - The import statement being analyzed
 * @param targetModule - The module being imported
 * @returns True when the importing module matches the imported module
 */
predicate modules_imports_itself(ImportingStmt importStatement, ModuleValue targetModule) {
  // Verify the importing module's scope matches the target module's scope
  importStatement.getEnclosingModule() = targetModule.getScope() and
  // Resolve the imported module name to its corresponding ModuleValue
  targetModule =
    max(string importedName, ModuleValue candidate |
      importedName = importStatement.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// Identify all instances where modules import themselves
from ImportingStmt importStatement, ModuleValue targetModule
where modules_imports_itself(importStatement, targetModule)
select importStatement, "The module '" + targetModule.getName() + "' imports itself."