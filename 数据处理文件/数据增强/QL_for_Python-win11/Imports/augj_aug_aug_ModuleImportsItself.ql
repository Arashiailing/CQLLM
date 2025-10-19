/**
 * @name Module imports itself
 * @description Detects modules that import themselves, which can lead to circular dependencies
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
 * Predicate to identify modules that import themselves
 * This predicate checks whether an import statement refers to the module that contains it
 */
predicate detectsSelfImport(ImportingStmt importDeclaration, ModuleValue moduleObject) {
  // Verify that the enclosing module of the import statement matches the scope of the imported module
  importDeclaration.getEnclosingModule() = moduleObject.getScope() and
  // Find the most appropriate module value through aggregation
  // We prioritize modules with the longest matching name to correctly handle relative imports
  moduleObject = 
    max(string importedName, ModuleValue candidate |
      importedName = importDeclaration.getAnImportedModuleName() and
      candidate.importedAs(importedName)
    |
      candidate order by importedName.length()
    )
}

// Find all instances of modules importing themselves
from ImportingStmt importDeclaration, ModuleValue targetModule
where detectsSelfImport(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."