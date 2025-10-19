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

// Predicate to check if an import statement is a basic import (without attributes)
predicate isBasicImport(Import imp) { not exists(Attribute a | imp.contains(a)) }

// Predicate to find duplicate imports within the same module
predicate hasDuplicateImport(Import firstImport, Import secondImport, Module targetModule) {
  // Ensure we're dealing with two distinct import statements
  firstImport != secondImport and
  // Both imports must be basic imports (without attributes)
  isBasicImport(firstImport) and
  isBasicImport(secondImport) and
  // Both imports reference the same module
  exists(ImportExpr firstExpr, ImportExpr secondExpr |
    firstExpr.getName() = targetModule.getName() and
    secondExpr.getName() = targetModule.getName() and
    firstExpr = firstImport.getAName().getValue() and
    secondExpr = secondImport.getAName().getValue()
  ) and
  // Both imports use the same alias
  firstImport.getAName().getAsname().(Name).getId() = secondImport.getAName().getAsname().(Name).getId() and
  // Check if both imports are in the same module
  exists(Module parentModule |
    firstImport.getScope() = parentModule and
    secondImport.getEnclosingModule() = parentModule and
    (
      // The second import is not at the top-level scope
      secondImport.getScope() != parentModule
      or
      // The first import appears before the second import in the code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Query to identify and report all instances of duplicate imports
from Import firstImport, Import secondImport, Module targetModule
where hasDuplicateImport(firstImport, secondImport, targetModule)
select secondImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()