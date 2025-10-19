/**
 * @name Redundant module import detection
 * @description Identifies duplicate module imports that serve no purpose and decrease code readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Helper predicate to check imports without attribute access
predicate is_plain_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Core predicate to find duplicate imports in same scope
predicate redundant_import(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure distinct simple imports
  firstImport != secondImport and
  is_plain_import(firstImport) and
  is_plain_import(secondImport) and
  
  // Verify identical module references and aliases
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = importedModule.getName() and
    secondModuleRef.getName() = importedModule.getName() and
    firstModuleRef = firstImport.getAName().getValue() and
    secondModuleRef = secondImport.getAName().getValue() and
    firstImport.getAName().getAsname().(Name).getId() = 
    secondImport.getAName().getAsname().(Name).getId()
  ) and
  
  // Validate scope hierarchy and order
  exists(Module parentModule |
    firstImport.getScope() = parentModule and
    secondImport.getEnclosingModule() = parentModule and
    (
      // Second import is in nested scope OR
      secondImport.getScope() != parentModule
      or
      // First import precedes second import
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Report redundant imports with location context
from Import firstImport, Import secondImport, Module importedModule
where redundant_import(firstImport, secondImport, importedModule)
select secondImport,
  "Duplicate import of module " + importedModule.getName() + " is unnecessary, previously imported $@.",
  firstImport, "at line " + firstImport.getLocation().getStartLine().toString()