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
 * Identifies self-importing modules by comparing importing and imported modules.
 * @param importStmt - The import statement being analyzed
 * @param importedModule - The module being imported
 * @returns True when the importing module matches the imported module
 */
predicate modules_imports_itself(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify the importing module's scope matches the target module's scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Resolve the imported module name to its corresponding ModuleValue
  importedModule =
    max(string moduleName, ModuleValue moduleCandidate |
      moduleName = importStmt.getAnImportedModuleName() and
      moduleCandidate.importedAs(moduleName)
    |
      moduleCandidate order by moduleName.length()
    )
}

// Identify all instances where modules import themselves
from ImportingStmt importStmt, ModuleValue importedModule
where modules_imports_itself(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."