/**
 * @name Module is imported more than once
 * @description Identifies when the same module is imported multiple times within the same scope
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate that checks if an import statement does not contain any attribute access
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attribute | importStmt.contains(attribute)) 
}

// Predicate to find duplicate imports of the same module with identical aliases
predicate double_import(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure we're dealing with two different import statements, both simple imports
  firstImport != secondImport and
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Check that both imports reference the same module
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = importedModule.getName() and
    secondModuleRef.getName() = importedModule.getName() and
    firstModuleRef = firstImport.getAName().getValue() and
    secondModuleRef = secondImport.getAName().getValue()
  ) and
  
  // Verify that both imports use the same alias
  firstImport.getAName().getAsname().(Name).getId() = 
  secondImport.getAName().getAsname().(Name).getId() and
  
  // Ensure both imports are within the same module and check their relative positions
  exists(Module containerModule |
    firstImport.getScope() = containerModule and
    secondImport.getEnclosingModule() = containerModule and
    (
      // Case 1: The second import is in a nested scope (not at module level)
      secondImport.getScope() != containerModule
      or
      // Case 2: The first import appears before the second import in the code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Main query to detect and report redundant duplicate imports
from Import firstImport, Import secondImport, Module importedModule
where double_import(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()