/**
 * @name Module imports itself
 * @description Detects when a module imports itself, which is typically a sign of redundant or unnecessary code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Helper predicate to identify modules that import themselves
predicate isSelfImportingModule(ImportingStmt importDeclaration, ModuleValue importedModule) {
  // Check if the importing module's scope matches the imported module's scope
  importDeclaration.getEnclosingModule() = importedModule.getScope() and
  // Find the actual module being imported, selecting the shortest matching name
  importedModule =
    max(string moduleName, ModuleValue resolvedModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      resolvedModule.importedAs(moduleName)
    |
      resolvedModule order by moduleName.length()
    )
}

// Main query to find all instances of modules importing themselves
from ImportingStmt importDeclaration, ModuleValue importedModule
where isSelfImportingModule(importDeclaration, importedModule)
select importDeclaration, "Module '" + importedModule.getName() + "' is importing itself."