/**
 * @name Module imports itself
 * @description Identifies modules that import themselves, a pattern that typically indicates
 *              a design issue or unnecessary code complexity.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Main query to find all instances of modules that import themselves
from ImportingStmt importDeclaration, ModuleValue importedModule
where 
  // Condition 1: The import statement must be within the module itself
  importDeclaration.getEnclosingModule() = importedModule.getScope() and
  // Condition 2: The imported module resolves to the same module,
  // using the shortest name to handle potential naming conflicts
  importedModule = max(string moduleName, ModuleValue resolvedModule |
      moduleName = importDeclaration.getAnImportedModuleName() and
      resolvedModule.importedAs(moduleName)
    | resolvedModule order by moduleName.length()
  )
select importDeclaration, "The module '" + importedModule.getName() + "' imports itself."