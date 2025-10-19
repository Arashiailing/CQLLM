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

// Predicate to determine if an import statement is simple (doesn't access module attributes)
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Predicate to identify duplicate imports within the same scope
predicate double_import(Import initialImport, Import duplicateImport, Module targetModule) {
  // Ensure imports are distinct and both are simple imports
  initialImport != duplicateImport and
  is_simple_import(initialImport) and
  is_simple_import(duplicateImport) and
  
  // Check if both imports reference the same module
  exists(ImportExpr moduleExpr1, ImportExpr moduleExpr2 |
    moduleExpr1 = initialImport.getAName().getValue() and
    moduleExpr2 = duplicateImport.getAName().getValue() and
    moduleExpr1.getName() = targetModule.getName() and
    moduleExpr2.getName() = targetModule.getName()
  ) and
  
  // Verify alias consistency
  (if exists(initialImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name aliasName1, Name aliasName2 |
       aliasName1 = initialImport.getAName().getAsname() and
       aliasName2 = duplicateImport.getAName().getAsname() and
       aliasName1.getId() = aliasName2.getId()
     )
   else 
     // Neither import has an alias
     not exists(duplicateImport.getAName().getAsname())
  ) and
  
  // Check scope and positioning constraints
  exists(Module parentModule |
    // Both imports must be in the same parent module
    initialImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    
    // Either the duplicate is not in top-level scope
    // or the initial import appears before the duplicate
    (duplicateImport.getScope() != parentModule or
     initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode()))
  )
}

// Find and report duplicate imports
from Import initialImport, Import duplicateImport, Module targetModule
where double_import(initialImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()