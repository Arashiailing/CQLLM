/**
 * @name Module is imported more than once
 * @description Detects instances where the same module is imported multiple times
 *              within the same scope, which is functionally redundant and decreases code readability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Determines if an import statement is simple (no attribute access)
predicate is_simple_import(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Identifies duplicate imports within the same scope
predicate duplicate_import_found(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure imports are distinct and both are simple
  firstImport != secondImport and
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    firstModuleExpr = firstImport.getAName().getValue() and
    secondModuleExpr = secondImport.getAName().getValue() and
    firstModuleExpr.getName() = importedModule.getName() and
    secondModuleExpr.getName() = importedModule.getName()
  ) and
  
  // Check alias consistency
  (if exists(firstImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name firstAlias, Name secondAlias |
       firstAlias = firstImport.getAName().getAsname() and
       secondAlias = secondImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(secondImport.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module enclosingModule |
    // Both imports must be in the same parent module
    firstImport.getScope() = enclosingModule and
    secondImport.getEnclosingModule() = enclosingModule and
    
    // Either the duplicate is not in top-level scope
    // or the first import appears before the second
    (secondImport.getScope() != enclosingModule or
     firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode()))
  )
}

// Report redundant imports
from Import firstImport, Import secondImport, Module importedModule
where duplicate_import_found(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()