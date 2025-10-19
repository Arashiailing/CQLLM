/**
 * @name Module is imported more than once
 * @description Importing a module a second time has no effect and impairs readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate to identify simple imports without attribute access
predicate is_simple_import(Import imp) { 
  not exists(Attribute attr | imp.contains(attr)) 
}

// Predicate to detect duplicate imports with same module and alias
predicate double_import(Import primaryImport, Import redundantImport, Module importedModule) {
  // Ensure imports are distinct and both are simple imports
  primaryImport != redundantImport and
  is_simple_import(primaryImport) and
  is_simple_import(redundantImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr primaryExpr, ImportExpr redundantExpr |
    primaryExpr.getName() = importedModule.getName() and
    redundantExpr.getName() = importedModule.getName() and
    primaryExpr = primaryImport.getAName().getValue() and
    redundantExpr = redundantImport.getAName().getValue()
  ) and
  
  // Confirm identical aliases are used
  primaryImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope and position relationships
  exists(Module enclosingScope |
    primaryImport.getScope() = enclosingScope and
    redundantImport.getEnclosingModule() = enclosingScope and
    (
      // Redundant import is in nested scope
      redundantImport.getScope() != enclosingScope
      or
      // Primary import appears before redundant import
      primaryImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant imports
from Import original, Import duplicate, Module m
where double_import(original, duplicate, m)
select duplicate,
  "This import of module " + m.getName() + " is redundant, as it was previously imported $@.",
  original, "on line " + original.getLocation().getStartLine().toString()