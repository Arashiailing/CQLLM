/**
 * @name Module imports itself
 * @description Identifies when a Python module imports itself, which is typically unnecessary code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Detects self-importing behavior in Python modules
// This predicate identifies cases where a module imports itself
predicate detectsSelfImport(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // The import statement's enclosing module must match the target module's scope
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // Among all modules matching the imported name, select the one with the longest name
  // This approach correctly handles relative imports by preferring the most specific match
  targetModule = 
    max(string importedName, ModuleValue candidate |
      // Find all modules that match the imported name
      importedName = importDeclaration.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      // Order by name length to select the most specific match
      candidate order by importedName.length()
    )
}

// Query to find all instances of modules importing themselves
from ImportingStmt importStatement, ModuleValue selfImportedModule
where detectsSelfImport(importStatement, selfImportedModule)
select importStatement, "The module '" + selfImportedModule.getName() + "' imports itself."