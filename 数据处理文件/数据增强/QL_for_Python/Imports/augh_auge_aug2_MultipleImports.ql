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
predicate isSimpleModuleImport(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Identifies duplicate imports of the same module within the same code scope
predicate isDuplicateImport(Import firstImportNode, Import secondImportNode, Module importedModule) {
  // Ensure imports are distinct statements
  firstImportNode != secondImportNode and
  // Both must be simple module imports
  isSimpleModuleImport(firstImportNode) and
  isSimpleModuleImport(secondImportNode) and
  /* Both imports reference the same target module */
  exists(ImportExpr firstImportExpr, ImportExpr secondImportExpr |
    firstImportExpr.getName() = importedModule.getName() and
    secondImportExpr.getName() = importedModule.getName() and
    firstImportExpr = firstImportNode.getAName().getValue() and
    secondImportExpr = secondImportNode.getAName().getValue()
  ) and
  // Both imports use identical aliases
  firstImportNode.getAName().getAsname().(Name).getId() = secondImportNode.getAName().getAsname().(Name).getId() and
  exists(Module enclosingModule |
    firstImportNode.getScope() = enclosingModule and
    secondImportNode.getEnclosingModule() = enclosingModule and
    (
      /* Redundant import is in nested scope (function/class) */
      secondImportNode.getScope() != enclosingModule
      or
      /* First import appears before second import in source code */
      firstImportNode.getAnEntryNode().dominates(secondImportNode.getAnEntryNode())
    )
  )
}

// Query to detect and report duplicate module imports
from Import firstImportNode, Import secondImportNode, Module importedModule
where isDuplicateImport(firstImportNode, secondImportNode, importedModule)
select secondImportNode,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImportNode, "on line " + firstImportNode.getLocation().getStartLine().toString()