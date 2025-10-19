/**
 * @name Module is imported more than once
 * @description Identifies instances where the same module is imported multiple times
 *              within the same scope, which is functionally unnecessary and reduces
 *              code clarity and maintainability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Helper predicate to detect imports that don't access module attributes
predicate has_no_attribute_access(Import imp) { 
  not exists(Attribute attr | imp.contains(attr)) 
}

// Main predicate to find duplicate imports of the same module
predicate has_duplicate_import(Import firstImport, Import secondImport, Module importedModule) {
  // Ensure both are simple imports and are distinct
  firstImport != secondImport and
  has_no_attribute_access(firstImport) and
  has_no_attribute_access(secondImport) and
  
  // Check if both imports reference the same module
  exists(ImportExpr moduleRef1, ImportExpr moduleRef2 |
    moduleRef1 = firstImport.getAName().getValue() and
    moduleRef2 = secondImport.getAName().getValue() and
    moduleRef1.getName() = importedModule.getName() and
    moduleRef2.getName() = importedModule.getName()
  ) and
  
  // Verify alias consistency between imports
  (if exists(firstImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name alias1, Name alias2 |
       alias1 = firstImport.getAName().getAsname() and
       alias2 = secondImport.getAName().getAsname() and
       alias1.getId() = alias2.getId()
     )
   else 
     // Neither import should have an alias
     not exists(secondImport.getAName().getAsname())
  ) and
  
  // Validate scope and positional relationship
  exists(Module containerModule |
    firstImport.getScope() = containerModule and
    secondImport.getEnclosingModule() = containerModule and
    (
      // Second import is in a nested scope OR
      secondImport.getScope() != containerModule
      or
      // First import appears before second in code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Query to locate and report redundant module imports
from Import firstImport, Import secondImport, Module importedModule
where has_duplicate_import(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()