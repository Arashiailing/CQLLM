/**
 * @name Module is imported more than once
 * @description Identifies redundant imports where the same module is imported multiple times
 *              within the same scope, reducing code readability and maintainability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Checks if an import statement doesn't use attribute access (simple import)
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

// Detects duplicate imports within the same scope with consistent aliases
predicate duplicate_import_found(Import firstImportStmt, Import secondImportStmt, Module targetModule) {
  // Ensure imports are distinct and both are simple imports
  firstImportStmt != secondImportStmt and
  is_simple_import(firstImportStmt) and
  is_simple_import(secondImportStmt) and
  
  // Verify both imports reference the same module by name
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    firstModuleExpr = firstImportStmt.getAName().getValue() and
    secondModuleExpr = secondImportStmt.getAName().getValue() and
    firstModuleExpr.getName() = targetModule.getName() and
    secondModuleExpr.getName() = targetModule.getName()
  ) and
  
  // Enforce alias consistency between imports
  (if exists(firstImportStmt.getAName().getAsname())
   then 
     // Both imports must have matching aliases
     exists(Name firstAlias, Name secondAlias |
       firstAlias = firstImportStmt.getAName().getAsname() and
       secondAlias = secondImportStmt.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import should have an alias
     not exists(secondImportStmt.getAName().getAsname())
  ) and
  
  // Validate scope containment and positioning constraints
  exists(Module parentModule |
    // Both imports must reside in the same parent module
    firstImportStmt.getScope() = parentModule and
    secondImportStmt.getEnclosingModule() = parentModule and
    
    // Position validation: either not in top-level scope or first import precedes second
    (secondImportStmt.getScope() != parentModule or
     firstImportStmt.getAnEntryNode().dominates(secondImportStmt.getAnEntryNode()))
  )
}

// Report redundant imports with location context
from Import firstImportStmt, Import secondImportStmt, Module targetModule
where duplicate_import_found(firstImportStmt, secondImportStmt, targetModule)
select secondImportStmt,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  firstImportStmt, "on line " + firstImportStmt.getLocation().getStartLine().toString()