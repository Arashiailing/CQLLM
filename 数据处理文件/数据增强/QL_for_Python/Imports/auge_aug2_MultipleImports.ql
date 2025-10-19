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

// Determines if an import is a simple module import (without attribute access)
predicate isSimpleModuleImport(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Identifies duplicate imports of the same module within the same code scope
predicate isDuplicateImport(Import firstImport, Import secondImport, Module targetModule) {
  // Ensure imports are distinct statements
  firstImport != secondImport and
  // Both must be simple module imports
  isSimpleModuleImport(firstImport) and
  isSimpleModuleImport(secondImport) and
  /* Both imports reference the same target module */
  exists(ImportExpr firstExpr, ImportExpr secondExpr |
    firstExpr.getName() = targetModule.getName() and
    secondExpr.getName() = targetModule.getName() and
    firstExpr = firstImport.getAName().getValue() and
    secondExpr = secondImport.getAName().getValue()
  ) and
  // Both imports use identical aliases
  firstImport.getAName().getAsname().(Name).getId() = secondImport.getAName().getAsname().(Name).getId() and
  exists(Module parentModule |
    firstImport.getScope() = parentModule and
    secondImport.getEnclosingModule() = parentModule and
    (
      /* Redundant import is in nested scope (function/class) */
      secondImport.getScope() != parentModule
      or
      /* First import appears before second import in source code */
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Query to detect and report duplicate module imports
from Import firstImport, Import secondImport, Module targetModule
where isDuplicateImport(firstImport, secondImport, targetModule)
select secondImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()