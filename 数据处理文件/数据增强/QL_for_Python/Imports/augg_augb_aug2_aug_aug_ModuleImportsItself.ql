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
 * Identifies modules that import themselves by comparing the context module
 * of an import statement with the module being imported. Uses longest-name
 * matching to handle relative imports correctly.
 */
predicate isSelfImporting(ImportingStmt importStatement, ModuleValue selfImportedModule) {
  // Verify the import occurs within the same module scope
  importStatement.getEnclosingModule() = selfImportedModule.getScope() and
  // Select the best matching module using longest-name resolution
  selfImportedModule = 
    max(string importedName, ModuleValue candidate |
      importedName = importStatement.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// Query to detect all instances of self-importing modules
from ImportingStmt importStatement, ModuleValue targetModule
where isSelfImporting(importStatement, targetModule)
select importStatement, "The module '" + targetModule.getName() + "' imports itself."