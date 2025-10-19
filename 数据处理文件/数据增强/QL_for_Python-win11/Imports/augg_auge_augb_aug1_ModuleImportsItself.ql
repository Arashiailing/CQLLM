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
 * This predicate identifies modules that import themselves by checking if the importing module
 * is the same as the module being imported.
 * @param importDeclaration - The import statement that is being analyzed
 * @param targetModule - The module that is being imported
 * @returns True if the module containing the import statement is the same as the imported module
 */
predicate modules_imports_itself(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // Check if the enclosing module of the import statement is the same as the scope of the imported module
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // Find the ModuleValue corresponding to the imported module name
  targetModule =
    max(string importedName, ModuleValue potentialModule |
      importedName = importDeclaration.getAnImportedModuleName() and
      potentialModule.importedAs(importedName)
    |
      potentialModule order by importedName.length()
    )
}

// Find all import statements where a module imports itself
from ImportingStmt importDeclaration, ModuleValue targetModule
where modules_imports_itself(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."