/**
 * @name Module imports itself
 * @description Identifies modules that perform self-import operations, typically indicating unnecessary code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Determines if an import statement references its own containing module
predicate isSelfImportingModule(ImportingStmt importDeclaration, ModuleValue importedModule) {
  // Validate that the importing context matches the imported module's scope
  importDeclaration.getEnclosingModule() = importedModule.getScope() and
  // Resolve the shortest matching module name to prevent ambiguous import matches
  importedModule = 
    min(string moduleName, ModuleValue resolvedModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      resolvedModule.importedAs(moduleName)
    | resolvedModule order by moduleName.length() asc
  )
}

// Query to locate all instances of self-importing modules
from ImportingStmt importDeclaration, ModuleValue importedModule
where isSelfImportingModule(importDeclaration, importedModule)
select importDeclaration, "The module '" + importedModule.getName() + "' imports itself."