/**
 * @name Duplicate module import detection
 * @description Identifies redundant imports where the same module is imported multiple times
 *              within a single scope, degrading code clarity and maintainability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate to check if import is a basic module import (without attribute access)
predicate is_basic_import(Import importDeclaration) { 
  not exists(Attribute attrNode | importDeclaration.contains(attrNode)) 
}

// Predicate to locate redundant imports sharing identical module and alias
predicate redundant_import_pair(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure distinct imports and both are basic imports
  firstImport != secondImport and
  is_basic_import(firstImport) and
  is_basic_import(secondImport) and
  
  // Verify both imports reference identical target module
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    firstModuleExpr = firstImport.getAName().getValue() and
    secondModuleExpr = secondImport.getAName().getValue() and
    firstModuleExpr.getName() = importedModule.getName() and
    secondModuleExpr.getName() = importedModule.getName()
  ) and
  
  // Enforce alias consistency between imports
  (if exists(firstImport.getAName().getAsname())
   then 
     // Both imports have aliases - verify they match
     exists(Name firstAlias, Name secondAlias |
       firstAlias = firstImport.getAName().getAsname() and
       secondAlias = secondImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(secondImport.getAName().getAsname())
  ) and
  
  // Validate scope and positional relationships
  exists(Module containerModule |
    // Both imports must reside in same parent module
    firstImport.getScope() = containerModule and
    secondImport.getEnclosingModule() = containerModule and
    
    // Positional constraint: either duplicate is nested in inner scope
    // or original import precedes duplicate in top-level scope
    (secondImport.getScope() != containerModule or
     firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode()))
  )
}

// Identify and report redundant import statements
from Import firstImport, Import secondImport, Module importedModule
where redundant_import_pair(firstImport, secondImport, importedModule)
select secondImport,
  "Redundant import of module " + importedModule.getName() + " previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()