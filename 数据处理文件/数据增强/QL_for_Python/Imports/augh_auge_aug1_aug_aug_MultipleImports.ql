/**
 * @name Module is imported more than once
 * @description Detects redundant module imports occurring multiple times
 *              within the same scope, unnecessarily increasing code size
 *              and reducing maintainability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Determine if an import statement is simple (no module attribute access)
predicate isSimpleImport(Import importStmt) { 
  not exists(Attribute moduleAttr | importStmt.contains(moduleAttr)) 
}

// Identify duplicate import pairs within the same scope
predicate duplicateImport(Import initialImport, Import redundantImport, Module targetModule) {
  // Ensure distinct imports and both are simple
  initialImport != redundantImport and
  isSimpleImport(initialImport) and
  isSimpleImport(redundantImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstModExpr, ImportExpr secondModExpr |
    firstModExpr = initialImport.getAName().getValue() and
    secondModExpr = redundantImport.getAName().getValue() and
    firstModExpr.getName() = targetModule.getName() and
    secondModExpr.getName() = targetModule.getName()
  ) and
  
  // Check alias consistency between imports
  (if exists(initialImport.getAName().getAsname())
   then 
     // Both imports must have matching aliases
     exists(Name firstAlias, Name secondAlias |
       firstAlias = initialImport.getAName().getAsname() and
       secondAlias = redundantImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import should have an alias
     not exists(redundantImport.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module parentModule |
    // Both imports must reside in the same parent module
    initialImport.getScope() = parentModule and
    redundantImport.getEnclosingModule() = parentModule and
    
    // Either duplicate is not in top-level scope
    // or initial import precedes the duplicate
    (redundantImport.getScope() != parentModule or
     initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode()))
  )
}

// Query to detect and report redundant import statements
from Import initialImport, Import redundantImport, Module targetModule
where duplicateImport(initialImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()