/**
 * @name Module imports itself
 * @description Detects modules that import themselves directly
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
 * Identifies self-referential imports through module scope comparison
 * 
 * This predicate detects Python modules that directly import themselves,
 * indicating potentially problematic circular dependencies or redundant imports.
 * 
 * Parameters:
 * - importStmt: The import statement being analyzed
 * - importedModule: The module being imported
 */
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify the importing context matches the imported module's scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Resolve the most specific module match using longest-name priority
  exists(string importedName | 
    importedName = importStmt.getAnImportedModuleName() and
    importedModule.importedAs(importedName) and
    // Ensure this is the longest matching module name
    forall(ModuleValue otherModule |
      otherModule.importedAs(importedName) |
      otherModule.getName().length() <= importedModule.getName().length()
    )
  )
}

// Main query: Identify all self-importing module instances
// 
// This query analyzes all import statements to detect self-imports,
// generating maintainability warnings for potentially problematic patterns.
from ImportingStmt importStmt, ModuleValue importedModule
where isSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."