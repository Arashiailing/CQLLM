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

// Check if an import statement is a simple module import (without accessing attributes)
predicate isSimpleModuleImport(Import importStmt) { 
  not exists(Attribute attribute | importStmt.contains(attribute)) 
}

// Helper predicate to verify if two imports reference the same module with the same alias
predicate importsSameModuleWithSameAlias(Import primaryImport, Import redundantImport, Module targetModule) {
  exists(ImportExpr primaryImportExpr, ImportExpr redundantImportExpr |
    // Both imports reference the same target module
    primaryImportExpr.getName() = targetModule.getName() and
    redundantImportExpr.getName() = targetModule.getName() and
    // Connect the expressions to their respective import statements
    primaryImportExpr = primaryImport.getAName().getValue() and
    redundantImportExpr = redundantImport.getAName().getValue() and
    // Both imports use identical aliases
    primaryImport.getAName().getAsname().(Name).getId() = redundantImport.getAName().getAsname().(Name).getId()
  )
}

// Helper predicate to verify if imports are in the same scope or nested appropriately
predicate importsInRelatedScope(Import primaryImport, Import redundantImport) {
  exists(Module parentModule |
    primaryImport.getScope() = parentModule and
    redundantImport.getEnclosingModule() = parentModule and
    (
      // Case 1: Redundant import is in a nested scope (function/class)
      redundantImport.getScope() != parentModule
      or
      // Case 2: Primary import appears before redundant import in source code
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Identifies duplicate imports of the same module within the same code scope
predicate isDuplicateImport(Import primaryImport, Import redundantImport, Module targetModule) {
  // Ensure imports are distinct statements
  primaryImport != redundantImport and
  // Both must be simple module imports
  isSimpleModuleImport(primaryImport) and
  isSimpleModuleImport(redundantImport) and
  // Check if they import the same module with the same alias
  importsSameModuleWithSameAlias(primaryImport, redundantImport, targetModule) and
  // Verify their scope relationship
  importsInRelatedScope(primaryImport, redundantImport)
}

// Query to detect and report duplicate module imports
from Import primaryImport, Import redundantImport, Module targetModule
where isDuplicateImport(primaryImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()