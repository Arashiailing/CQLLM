/**
 * @name Module imports itself
 * @description Detects when a module imports itself directly
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Identifies self-referencing import statements
// Matches when an import statement's enclosing module matches the imported module
predicate selfImportExists(ImportingStmt importStmt, ModuleValue selfModule) {
  // Verify the import occurs within the target module's scope
  importStmt.getEnclosingModule() = selfModule.getScope() and
  // Resolve the most specific module match using longest-name precedence
  // Handles relative imports by prioritizing fully qualified names
  selfModule = 
    max(string importedName, ModuleValue candidate |
      importedName = importStmt.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length() desc
    )
}

// Locate all modules performing self-import operations
from ImportingStmt importStmt, ModuleValue selfModule
where selfImportExists(importStmt, selfModule)
select importStmt, "The module '" + selfModule.getName() + "' imports itself."