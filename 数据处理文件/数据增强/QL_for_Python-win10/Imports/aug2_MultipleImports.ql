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

// Predicate to determine if an import statement is a basic import (without attributes)
predicate isBasicImport(Import imp) { not exists(Attribute a | imp.contains(a)) }

// Predicate to identify duplicate imports within the same module
predicate hasDuplicateImport(Import primaryImport, Import redundantImport, Module importedModule) {
  // Ensure the primary and redundant imports are not the same statement
  primaryImport != redundantImport and
  // Both imports must be basic imports (without attributes)
  isBasicImport(primaryImport) and
  isBasicImport(redundantImport) and
  /* Both imports reference the same module */
  exists(ImportExpr firstImportExpr, ImportExpr secondImportExpr |
    firstImportExpr.getName() = importedModule.getName() and
    secondImportExpr.getName() = importedModule.getName() and
    firstImportExpr = primaryImport.getAName().getValue() and
    secondImportExpr = redundantImport.getAName().getValue()
  ) and
  // Both imports use the same alias
  primaryImport.getAName().getAsname().(Name).getId() = redundantImport.getAName().getAsname().(Name).getId() and
  exists(Module enclosingModule |
    primaryImport.getScope() = enclosingModule and
    redundantImport.getEnclosingModule() = enclosingModule and
    (
      /* The redundant import is not at the top-level scope */
      redundantImport.getScope() != enclosingModule
      or
      /* The primary import appears before the redundant import in the code */
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Query to find all instances of duplicate imports and report them
from Import primaryImport, Import redundantImport, Module importedModule
where hasDuplicateImport(primaryImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()