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
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Identifies duplicate imports within the same scope
predicate duplicate_import_found(Import firstImportStmt, Import secondImportStmt, Module duplicateModule) {
  // Ensure imports are distinct and both are simple
  firstImportStmt != secondImportStmt and
  is_simple_import(firstImportStmt) and
  is_simple_import(secondImportStmt) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstImportExpr, ImportExpr secondImportExpr |
    firstImportExpr = firstImportStmt.getAName().getValue() and
    secondImportExpr = secondImportStmt.getAName().getValue() and
    firstImportExpr.getName() = duplicateModule.getName() and
    secondImportExpr.getName() = duplicateModule.getName()
  ) and
  
  // Check alias consistency
  (if exists(firstImportStmt.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name firstAliasName, Name secondAliasName |
       firstAliasName = firstImportStmt.getAName().getAsname() and
       secondAliasName = secondImportStmt.getAName().getAsname() and
       firstAliasName.getId() = secondAliasName.getId()
     )
   else 
     // Neither import has an alias
     not exists(secondImportStmt.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module parentModule |
    // Both imports must be in the same parent module
    firstImportStmt.getEnclosingModule() = parentModule and
    secondImportStmt.getEnclosingModule() = parentModule and
    
    // Either the duplicate is not in top-level scope
    // or the first import appears before the second
    (secondImportStmt.getScope() != parentModule or
     firstImportStmt.getAnEntryNode().dominates(secondImportStmt.getAnEntryNode()))
  )
}

// Report redundant imports
from Import firstImportStmt, Import secondImportStmt, Module duplicateModule
where duplicate_import_found(firstImportStmt, secondImportStmt, duplicateModule)
select secondImportStmt,
  "This import of module " + duplicateModule.getName() + " is redundant, as it was previously imported $@.",
  firstImportStmt, "on line " + firstImportStmt.getLocation().getStartLine().toString()