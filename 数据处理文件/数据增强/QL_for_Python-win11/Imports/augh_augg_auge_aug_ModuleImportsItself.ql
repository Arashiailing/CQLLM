/**
 * @name Module imports itself
 * @description Identifies modules that import themselves, which typically indicates redundant or unnecessary code structures
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Helper predicate to detect modules that perform self-imports
predicate isSelfImportingModule(ImportingStmt importStatement, ModuleValue selfImportedModule) {
  // Verify that the importing module's scope is identical to the imported module's scope
  importStatement.getEnclosingModule() = selfImportedModule.getScope() and
  // Determine the actual module being imported by selecting the shortest matching name
  selfImportedModule =
    max(string importName, ModuleValue resolvedImport |
      importName = importStatement.getAnImportedModuleName() and
      resolvedImport.importedAs(importName)
    |
      resolvedImport order by importName.length()
    )
}

// Primary query to locate all instances where modules import themselves
from ImportingStmt importStatement, ModuleValue selfImportedModule
where isSelfImportingModule(importStatement, selfImportedModule)
select importStatement, "Module '" + selfImportedModule.getName() + "' is importing itself."