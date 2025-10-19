/**
 * @name Redundant module import detected
 * @description Identifies duplicate module imports that have no effect and reduce code clarity
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Helper predicate to verify imports without attribute access
predicate is_simple_import(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Core predicate to identify duplicate imports within same scope
predicate duplicate_import(Import initialImport, Import redundantImport, Module targetModule) {
  // Verify distinct simple imports
  initialImport != redundantImport and
  is_simple_import(initialImport) and
  is_simple_import(redundantImport) and
  
  // Confirm identical module references
  exists(ImportExpr initialModuleRef, ImportExpr redundantModuleRef |
    initialModuleRef.getName() = targetModule.getName() and
    redundantModuleRef.getName() = targetModule.getName() and
    initialModuleRef = initialImport.getAName().getValue() and
    redundantModuleRef = redundantImport.getAName().getValue()
  ) and
  
  // Validate matching aliases
  initialImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // Check scope containment and positioning
  exists(Module containerModule |
    initialImport.getScope() = containerModule and
    redundantImport.getEnclosingModule() = containerModule and
    (
      // Redundant import is in nested scope OR
      redundantImport.getScope() != containerModule
      or
      // Initial import appears before redundant import
      initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Report redundant imports with location context
from Import initialImport, Import redundantImport, Module targetModule
where duplicate_import(initialImport, redundantImport, targetModule)
select redundantImport,
  "Duplicate import of module " + targetModule.getName() + " is unnecessary, previously imported $@.",
  initialImport, "at line " + initialImport.getLocation().getStartLine().toString()