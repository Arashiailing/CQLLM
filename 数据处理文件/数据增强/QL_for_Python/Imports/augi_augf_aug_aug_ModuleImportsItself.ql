/**
 * @name Module imports itself
 * @description Identifies when a Python module imports itself, which is typically unnecessary code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

// Identifies instances where a Python module performs a self-import
// This predicate captures the relationship between an import statement and the module it imports
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // The module containing the import statement must be the same as the module being imported
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Among all modules that match the imported name, select the one with the most specific (longest) name
  // This strategy ensures correct handling of relative imports by prioritizing specificity
  importedModule = 
    max(string moduleName, ModuleValue moduleCandidate |
      // Identify all modules that correspond to the name used in the import statement
      moduleName = importStmt.getAnImportedModuleName() and
      moduleCandidate.importedAs(moduleName)
    |
      // Sort candidates by name length to select the most specific match
      moduleCandidate order by moduleName.length()
    )
}

// Query to detect and report all occurrences of modules importing themselves
from ImportingStmt importDeclaration, ModuleValue selfModule
where isSelfImport(importDeclaration, selfModule)
select importDeclaration, "The module '" + selfModule.getName() + "' imports itself."