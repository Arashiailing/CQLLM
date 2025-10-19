/**
 * @name Module is imported more than once
 * @description Identifies when a module is imported multiple times within the same codebase,
 *              which has no functional effect but reduces code readability.
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
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attribute | importStmt.contains(attribute)) 
}

// Checks if two imports satisfy the basic conditions for being potential duplicates
predicate basic_duplicate_conditions(Import primaryImport, Import duplicateImport) {
  // Ensure the imports are different and both are simple imports
  primaryImport != duplicateImport and
  is_simple_import(primaryImport) and
  is_simple_import(duplicateImport)
}

// Verifies that two imports reference the same module
predicate imports_same_module(Import primaryImport, Import duplicateImport, Module targetModule) {
  exists(ImportExpr primaryExpr, ImportExpr duplicateExpr |
    primaryExpr.getName() = targetModule.getName() and
    duplicateExpr.getName() = targetModule.getName() and
    primaryExpr = primaryImport.getAName().getValue() and
    duplicateExpr = duplicateImport.getAName().getValue()
  )
}

// Confirms that two imports use the same alias
predicate same_alias_used(Import primaryImport, Import duplicateImport) {
  primaryImport.getAName().getAsname().(Name).getId() = 
  duplicateImport.getAName().getAsname().(Name).getId()
}

// Validates the scope and positional relationship between two imports
predicate valid_scope_and_position(Import primaryImport, Import duplicateImport) {
  exists(Module parentModule |
    primaryImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Case 1: The duplicate import is not in the top-level scope
      duplicateImport.getScope() != parentModule
      or
      // Case 2: The primary import appears before the duplicate import in the code
      primaryImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Core logic for detecting duplicate imports
predicate double_import(Import primaryImport, Import duplicateImport, Module targetModule) {
  basic_duplicate_conditions(primaryImport, duplicateImport) and
  imports_same_module(primaryImport, duplicateImport, targetModule) and
  same_alias_used(primaryImport, duplicateImport) and
  valid_scope_and_position(primaryImport, duplicateImport)
}

// Query and report duplicate import issues
from Import primaryImport, Import duplicateImport, Module targetModule
where double_import(primaryImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()