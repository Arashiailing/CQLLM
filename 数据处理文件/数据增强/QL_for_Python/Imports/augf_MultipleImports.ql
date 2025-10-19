/**
 * @name Module is imported more than once
 * @description Detects redundant imports of the same module which have no effect and reduce code readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Helper predicate to identify basic imports (without attribute access)
predicate isBasicImport(Import imp) { not exists(Attribute a | imp.contains(a)) }

// Helper predicate to check if two imports reference the same module with identical aliases
predicate importsSameModuleWithAlias(Import firstImport, Import secondImport, Module targetModule) {
  exists(ImportExpr expr1, ImportExpr expr2 |
    expr1.getName() = targetModule.getName() and
    expr2.getName() = targetModule.getName() and
    expr1 = firstImport.getAName().getValue() and
    expr2 = secondImport.getAName().getValue() and
    firstImport.getAName().getAsname().(Name).getId() = secondImport.getAName().getAsname().(Name).getId()
  )
}

// Helper predicate to validate import ordering and scope relationship
predicate hasValidImportOrdering(Import firstImport, Import secondImport, Module containerModule) {
  firstImport.getScope() = containerModule and
  secondImport.getEnclosingModule() = containerModule and
  (
    // Case 1: Redundant import is not at the top level
    secondImport.getScope() != containerModule
    or
    // Case 2: Original import appears before the redundant one in code
    firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
  )
}

// Main predicate to detect redundant import scenarios
predicate hasRedundantImport(Import primaryImport, Import redundantImport, Module importedModule) {
  // Ensure we're not comparing the same import statement
  primaryImport != redundantImport and
  // Both imports must be basic imports (without attributes)
  isBasicImport(primaryImport) and
  isBasicImport(redundantImport) and
  // Verify they import the same module with the same alias
  importsSameModuleWithAlias(primaryImport, redundantImport, importedModule) and
  // Check proper ordering and scope relationship
  exists(Module enclosingModule | hasValidImportOrdering(primaryImport, redundantImport, enclosingModule))
}

// Main query to identify and report redundant imports
from Import primaryImport, Import redundantImport, Module importedModule
where hasRedundantImport(primaryImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()