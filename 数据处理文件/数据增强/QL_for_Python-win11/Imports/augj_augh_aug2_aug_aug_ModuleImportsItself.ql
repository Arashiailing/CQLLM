/**
 * @name Module imports itself
 * @description Detects when a module imports itself, which is typically a coding error
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Helper predicate to determine if a module imports itself
// This occurs when the module containing an import statement
// is the same as the module being imported
predicate hasSelfImport(ImportingStmt importDeclaration, ModuleValue importedModule) {
  // Step 1: Find the best matching module for the import statement
  importedModule = 
    max(string moduleName, ModuleValue candidateModule |
      // Get the module name referenced by the import statement
      moduleName = importDeclaration.getAnImportedModuleName() and
      // Find all modules that can be imported with this name
      candidateModule.importedAs(moduleName)
    |
      // Prefer the longest name match to correctly handle relative imports
      candidateModule order by moduleName.length()
    ) and
  // Step 2: Verify that the module containing the import statement
  // is the same as the scope of the imported module
  importDeclaration.getEnclosingModule() = importedModule.getScope()
}

// Query to find all instances of self-importing modules
from ImportingStmt importDeclaration, ModuleValue selfReferencedModule
where hasSelfImport(importDeclaration, selfReferencedModule)
select importDeclaration, "The module '" + selfReferencedModule.getName() + "' imports itself."