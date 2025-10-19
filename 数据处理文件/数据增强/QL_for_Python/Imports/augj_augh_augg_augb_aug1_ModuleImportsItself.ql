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
 * This query identifies modules that import themselves by examining the relationship
 * between importing statements and their target modules. It resolves the imported
 * module names and selects the shortest match to ensure accurate identification
 * and avoid ambiguous references.
 */
from ImportingStmt importDeclaration, ModuleValue targetModule
where 
  // Verify that the scope of the importing module matches the scope of the imported module
  importDeclaration.getEnclosingModule() = targetModule.getScope()
  and
  // Resolve the name of the imported module and find the shortest matching module
  exists(string resolvedModuleName |
    resolvedModuleName = importDeclaration.getAnImportedModuleName()
    and
    targetModule = min(ModuleValue potentialMatch |
      potentialMatch.importedAs(resolvedModuleName)
    |
      potentialMatch order by resolvedModuleName.length()
    )
  )
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."