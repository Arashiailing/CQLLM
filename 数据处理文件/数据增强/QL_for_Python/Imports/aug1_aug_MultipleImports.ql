/**
 * @name Module is imported more than once
 * @description Importing a module a second time has no effect and impairs readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate to identify imports without attribute access
predicate is_simple_import(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Predicate to detect duplicate imports within the same scope
predicate double_import(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure imports are distinct and simple
  firstImport != secondImport and
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = importedModule.getName() and
    secondModuleRef.getName() = importedModule.getName() and
    firstModuleRef = firstImport.getAName().getValue() and
    secondModuleRef = secondImport.getAName().getValue()
  ) and
  
  // Confirm identical aliases are used
  firstImport.getAName().getAsname().(Name).getId() = 
  secondImport.getAName().getAsname().(Name).getId() and
  
  // Check scope and positioning constraints
  exists(Module parentModule |
    firstImport.getScope() = parentModule and
    secondImport.getEnclosingModule() = parentModule and
    (
      // Duplicate is not in top-level scope OR
      secondImport.getScope() != parentModule
      or
      // First import appears before duplicate in code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Identify and report duplicate imports
from Import firstImport, Import secondImport, Module importedModule
where double_import(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()