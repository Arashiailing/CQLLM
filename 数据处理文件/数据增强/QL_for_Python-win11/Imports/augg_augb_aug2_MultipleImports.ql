/**
 * @name Redundant module import detection
 * @description Identifies duplicate module imports that reduce code maintainability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Determines if an import statement is a simple import (without attribute access)
predicate isSimpleImport(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Identifies pairs of duplicate imports targeting the same module
predicate findDuplicateImports(Import primaryImport, Import redundantImport, Module importedModule) {
  // Ensure imports are distinct and both are simple imports
  primaryImport != redundantImport and
  isSimpleImport(primaryImport) and
  isSimpleImport(redundantImport) and
  // Verify both imports reference the same target module
  exists(ImportExpr primaryImportExpr, ImportExpr redundantImportExpr |
    primaryImportExpr.getName() = importedModule.getName() and
    redundantImportExpr.getName() = importedModule.getName() and
    primaryImportExpr = primaryImport.getAName().getValue() and
    redundantImportExpr = redundantImport.getAName().getValue()
  ) and
  // Confirm identical alias usage between imports
  primaryImport.getAName().getAsname().(Name).getId() = redundantImport.getAName().getAsname().(Name).getId() and
  // Validate import location relationships within the same module
  exists(Module enclosingModule |
    primaryImport.getScope() = enclosingModule and
    redundantImport.getEnclosingModule() = enclosingModule and
    (
      // Case 1: Redundant import is nested within function/class scope
      redundantImport.getScope() != enclosingModule
      or
      // Case 2: Primary import appears earlier in code execution order
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Query to locate and report all duplicate import instances
from Import primaryImport, Import redundantImport, Module importedModule
where findDuplicateImports(primaryImport, redundantImport, importedModule)
select redundantImport,
  "Redundant import of module " + importedModule.getName() + " previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()