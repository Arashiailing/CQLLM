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

// Identifies self-import scenarios where a module imports itself
// Matches when the importing module scope equals the imported module scope
predicate hasSelfImport(ImportingStmt importStatement, ModuleValue moduleValue) {
  // Verify the importing context matches the imported module's scope
  importStatement.getEnclosingModule() = moduleValue.getScope() and
  // Resolve the most specific module match using longest name resolution
  // Handles relative imports by prioritizing longest matching module names
  moduleValue = 
    max(string moduleName, ModuleValue candidateModule |
      moduleName = importStatement.getAnImportedModuleName() and
      candidateModule.importedAs(moduleName)
    |
      candidateModule order by moduleName.length()
    )
}

// Find all instances of modules importing themselves
from ImportingStmt importStatement, ModuleValue moduleValue
where hasSelfImport(importStatement, moduleValue)
select importStatement, "The module '" + moduleValue.getName() + "' imports itself."