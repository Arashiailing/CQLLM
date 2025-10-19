/**
 * @name Module is imported more than once
 * @description Detects redundant module imports within the same scope.
 *              Duplicate imports have no functional effect and reduce code readability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Identifies imports without attribute access (e.g., not 'import module.attr')
predicate isBareImport(Import impStmt) { 
  not exists(Attribute attr | impStmt.contains(attr)) 
}

// Detects duplicate imports with identical module and alias
predicate hasDuplicateImport(Import primaryImport, Import redundantImport, Module targetModule) {
  // Ensure distinct simple imports
  primaryImport != redundantImport and
  isBareImport(primaryImport) and
  isBareImport(redundantImport) and
  
  // Verify both reference the same module
  exists(ImportExpr primaryRef, ImportExpr redundantRef |
    primaryRef.getName() = targetModule.getName() and
    redundantRef.getName() = targetModule.getName() and
    primaryRef = primaryImport.getAName().getValue() and
    redundantRef = redundantImport.getAName().getValue()
  ) and
  
  // Confirm matching aliases
  primaryImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope and positioning constraints
  exists(Module commonScope |
    primaryImport.getScope() = commonScope and
    redundantImport.getEnclosingModule() = commonScope and
    (
      // Redundant import is not in top-level scope OR
      redundantImport.getScope() != commonScope
      or
      // Primary import precedes redundant import in code
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Report redundant imports with reference to original import
from Import primaryImport, Import redundantImport, Module targetModule
where hasDuplicateImport(primaryImport, redundantImport, targetModule)
select redundantImport,
  "Redundant import of module '" + targetModule.getName() + 
  "' previously imported $@.",
  primaryImport, "at line " + primaryImport.getLocation().getStartLine().toString()