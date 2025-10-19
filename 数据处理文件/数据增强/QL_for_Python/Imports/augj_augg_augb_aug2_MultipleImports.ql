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

// Checks if an import statement is a simple import (without any attribute access)
predicate isBasicImport(Import importDeclaration) { 
  not exists(Attribute attributeAccess | importDeclaration.contains(attributeAccess)) 
}

// Finds pairs of duplicate imports that reference the same module
predicate identifyRedundantImports(Import originalImport, Import duplicateImport, Module targetModule) {
  // Ensure the imports are different and both are basic imports
  originalImport != duplicateImport and
  isBasicImport(originalImport) and
  isBasicImport(duplicateImport) and
  // Verify both imports reference the same target module
  exists(ImportExpr originalImportExpr, ImportExpr duplicateImportExpr |
    originalImportExpr.getName() = targetModule.getName() and
    duplicateImportExpr.getName() = targetModule.getName() and
    originalImportExpr = originalImport.getAName().getValue() and
    duplicateImportExpr = duplicateImport.getAName().getValue()
  ) and
  // Check that both imports use the same alias
  originalImport.getAName().getAsname().(Name).getId() = duplicateImport.getAName().getAsname().(Name).getId() and
  // Validate the import location relationships within the same module
  exists(Module containerModule |
    originalImport.getScope() = containerModule and
    duplicateImport.getEnclosingModule() = containerModule and
    (
      // Case 1: Duplicate import is within a nested scope (function/class)
      duplicateImport.getScope() != containerModule
      or
      // Case 2: Original import appears earlier in the execution flow
      originalImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Main query to identify and report all redundant import instances
from Import originalImport, Import duplicateImport, Module targetModule
where identifyRedundantImports(originalImport, duplicateImport, targetModule)
select duplicateImport,
  "Redundant import of module " + targetModule.getName() + " previously imported $@.",
  originalImport, "on line " + originalImport.getLocation().getStartLine().toString()