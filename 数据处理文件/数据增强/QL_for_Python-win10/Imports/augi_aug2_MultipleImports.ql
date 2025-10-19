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

// Determines if an import statement is a basic import (without attributes)
predicate isBasicImport(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Identifies duplicate imports within the same module
predicate hasDuplicateImport(
  Import primaryImportStmt, 
  Import redundantImportStmt, 
  Module targetModule
) {
  // Ensure imports are distinct statements
  primaryImportStmt != redundantImportStmt and
  // Both must be basic imports (without attributes)
  isBasicImport(primaryImportStmt) and
  isBasicImport(redundantImportStmt) and
  // Verify both imports reference the same module
  exists(
    ImportExpr primaryImportExpr, 
    ImportExpr redundantImportExpr |
    primaryImportExpr.getName() = targetModule.getName() and
    redundantImportExpr.getName() = targetModule.getName() and
    primaryImportExpr = primaryImportStmt.getAName().getValue() and
    redundantImportExpr = redundantImportStmt.getAName().getValue()
  ) and
  // Both imports must use identical aliases
  primaryImportStmt.getAName().getAsname().(Name).getId() = 
  redundantImportStmt.getAName().getAsname().(Name).getId() and
  // Check scope conditions within the same module
  exists(Module enclosingModule |
    primaryImportStmt.getScope() = enclosingModule and
    redundantImportStmt.getEnclosingModule() = enclosingModule and
    (
      // Redundant import is in nested scope (function/class)
      redundantImportStmt.getScope() != enclosingModule
      or
      // Primary import appears before redundant import in code
      primaryImportStmt.getAnEntryNode().dominates(redundantImportStmt.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant imports
from Import primaryImportStmt, Import redundantImportStmt, Module targetModule
where hasDuplicateImport(primaryImportStmt, redundantImportStmt, targetModule)
select redundantImportStmt,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImportStmt, "on line " + primaryImportStmt.getLocation().getStartLine().toString()