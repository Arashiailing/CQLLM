/**
 * @name Duplicate Module Import
 * @description Redundant import of a module that was previously imported, which is unnecessary and reduces code clarity
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Check if import is simple (no attribute access)
predicate is_simple_import(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Detect redundant imports within same scope
predicate duplicate_import(Import initialImport, Import redundantImport, Module targetModule) {
  // Ensure imports are distinct and simple
  initialImport != redundantImport and
  is_simple_import(initialImport) and
  is_simple_import(redundantImport) and
  
  // Verify both imports reference same module
  exists(ImportExpr initialModuleRef, ImportExpr redundantModuleRef |
    initialModuleRef.getName() = targetModule.getName() and
    redundantModuleRef.getName() = targetModule.getName() and
    initialModuleRef = initialImport.getAName().getValue() and
    redundantModuleRef = redundantImport.getAName().getValue()
  ) and
  
  // Confirm identical aliases are used
  initialImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope and positioning constraints
  exists(Module parentModule |
    initialImport.getScope() = parentModule and
    redundantImport.getEnclosingModule() = parentModule and
    (
      // Redundant import not in top-level scope OR
      redundantImport.getScope() != parentModule
      or
      // Initial import appears before redundant import
      initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Identify and report redundant imports
from Import initialImport, Import redundantImport, Module targetModule
where duplicate_import(initialImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()