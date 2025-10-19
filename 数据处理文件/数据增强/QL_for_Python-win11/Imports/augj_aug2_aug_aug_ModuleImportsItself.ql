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

/* Identifies modules that import themselves, which is typically unnecessary code.
   This predicate checks if the enclosing module of an import statement matches
   the scope of the imported module reference. */
predicate selfImportDetected(ImportingStmt importStmt, ModuleValue importedModule) {
  /* The enclosing module of the import statement must match the scope
     of the imported module reference for it to be a self-import */
  importStmt.getEnclosingModule() = importedModule.getScope() and
  /* Select the best matching module reference, preferring the longest name match
     to correctly handle relative imports and ambiguous module names */
  importedModule = 
    max(string importName, ModuleValue candidateModule |
      importName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importName)
    |
      candidateModule order by importName.length()
    )
}

/* Query to find all instances of modules that import themselves */
from ImportingStmt importStmt, ModuleValue selfImportedModule
where selfImportDetected(importStmt, selfImportedModule)
select importStmt, "The module '" + selfImportedModule.getName() + "' imports itself."