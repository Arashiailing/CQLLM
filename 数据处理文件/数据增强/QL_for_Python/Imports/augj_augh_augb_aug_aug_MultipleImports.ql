/**
 * @name Redundant module import detection
 * @description Identifies duplicate imports of the same module within the same scope,
 *              which are functionally unnecessary and reduce code clarity.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Helper predicate to identify imports without attribute access
predicate lacks_attribute_access(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Core predicate to detect redundant module imports
predicate identifies_redundant_import(Import primaryImport, Import redundantImport, Module targetModule) {
  // Validate distinct imports without attribute access
  primaryImport != redundantImport and
  lacks_attribute_access(primaryImport) and
  lacks_attribute_access(redundantImport) and
  
  // Verify both imports reference identical modules
  exists(ImportExpr importExpr1, ImportExpr importExpr2 |
    importExpr1 = primaryImport.getAName().getValue() and
    importExpr2 = redundantImport.getAName().getValue() and
    importExpr1.getName() = targetModule.getName() and
    importExpr2.getName() = targetModule.getName()
  ) and
  
  // Ensure consistent alias handling
  (if exists(primaryImport.getAName().getAsname())
   then 
     // Both imports must have matching aliases
     exists(Name aliasName1, Name aliasName2 |
       aliasName1 = primaryImport.getAName().getAsname() and
       aliasName2 = redundantImport.getAName().getAsname() and
       aliasName1.getId() = aliasName2.getId()
     )
   else 
     // Neither import should have aliases
     not exists(redundantImport.getAName().getAsname())
  ) and
  
  // Confirm scope containment and code ordering
  exists(Module parentModule |
    primaryImport.getScope() = parentModule and
    redundantImport.getEnclosingModule() = parentModule and
    (
      // Redundant import is in nested scope OR
      redundantImport.getScope() != parentModule
      or
      // Primary import appears before redundant import
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant module imports
from Import primaryImport, Import redundantImport, Module targetModule
where identifies_redundant_import(primaryImport, redundantImport, targetModule)
select redundantImport,
  "Redundant import of module " + targetModule.getName() + " previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()