/**
 * @name Module is imported more than once
 * @description Identifies redundant module imports that impair code readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Determines if an import statement is a simple module import (without attribute access)
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Core logic for detecting duplicate imports with identical module and alias
predicate double_import(Import primaryImport, Import duplicateImport, Module targetModule) {
  // Basic validation: distinct imports, both simple imports
  primaryImport != duplicateImport and
  is_simple_import(primaryImport) and
  is_simple_import(duplicateImport) and
  
  // Module equivalence: both imports reference the same target module
  exists(ImportExpr primaryExpr, ImportExpr duplicateExpr |
    primaryExpr.getName() = targetModule.getName() and
    duplicateExpr.getName() = targetModule.getName() and
    primaryExpr = primaryImport.getAName().getValue() and
    duplicateExpr = duplicateImport.getAName().getValue()
  ) and
  
  // Alias consistency: identical aliases used for both imports
  primaryImport.getAName().getAsname().(Name).getId() = 
  duplicateImport.getAName().getAsname().(Name).getId() and
  
  // Scope and position validation
  exists(Module parentModule |
    primaryImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Case 1: Redundant import appears in nested scope
      duplicateImport.getScope() != parentModule
      or
      // Case 2: Primary import appears earlier in code
      primaryImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Query execution and result reporting
from Import primaryImport, Import duplicateImport, Module targetModule
where double_import(primaryImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()