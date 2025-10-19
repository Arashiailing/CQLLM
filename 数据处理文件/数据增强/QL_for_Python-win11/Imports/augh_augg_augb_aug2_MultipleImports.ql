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

// Checks if an import statement is a basic import without any attribute access
predicate isSimpleImport(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Finds pairs of duplicate imports that reference the same module with identical aliasing
predicate findDuplicateImports(Import mainImport, Import duplicateImport, Module targetModule) {
  // Basic validation: imports must be different and both must be simple imports
  mainImport != duplicateImport and
  isSimpleImport(mainImport) and
  isSimpleImport(duplicateImport) and
  // Extract and compare import expressions to verify they target the same module
  exists(ImportExpr mainImportExpr, ImportExpr duplicateImportExpr |
    mainImportExpr.getName() = targetModule.getName() and
    duplicateImportExpr.getName() = targetModule.getName() and
    mainImportExpr = mainImport.getAName().getValue() and
    duplicateImportExpr = duplicateImport.getAName().getValue() and
    // Ensure both imports use the same alias (if any)
    mainImport.getAName().getAsname().(Name).getId() = duplicateImport.getAName().getAsname().(Name).getId()
  ) and
  // Verify both imports exist within the same parent module
  exists(Module parentModule |
    mainImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Scenario 1: Duplicate import is in a nested scope (function/class)
      duplicateImport.getScope() != parentModule
      or
      // Scenario 2: Main import appears earlier in the execution flow
      mainImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Main query to identify and report all instances of redundant imports
from Import mainImport, Import duplicateImport, Module targetModule
where findDuplicateImports(mainImport, duplicateImport, targetModule)
select duplicateImport,
  "Redundant import of module " + targetModule.getName() + " previously imported $@.",
  mainImport, "on line " + mainImport.getLocation().getStartLine().toString()