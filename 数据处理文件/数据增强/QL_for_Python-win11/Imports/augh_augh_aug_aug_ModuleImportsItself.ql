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

// Identifies self-import scenarios where a module imports itself
// by matching the importing module's scope with the imported module's scope
// and selecting the most specific match using longest name resolution
predicate isSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // Verify the importing and imported modules share the same scope
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // Resolve the most specific module reference using longest-name matching
  // to handle relative imports correctly (e.g., '.module' vs 'package.module')
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      importedName = importStmt.getAnImportedModuleName() and
      candidateModule.importedAs(importedName)
    |
      candidateModule order by importedName.length() desc
    )
}

// Main query: Find all self-importing modules and generate alerts
from ImportingStmt importStmt, ModuleValue importedModule
where isSelfImport(importStmt, importedModule)
select importStmt, "Self-import detected: Module '" + importedModule.getName() + "' imports itself."