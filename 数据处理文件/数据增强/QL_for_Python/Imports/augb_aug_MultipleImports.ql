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

/**
 * Identifies import statements that don't access module attributes.
 * Such imports are considered "simple" imports without attribute references.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Detects redundant module imports within the same scope.
 * 
 * @param initialImport - The first occurrence of the import
 * @param redundantImport - The duplicate import statement
 * @param targetModule - The module being imported redundantly
 */
predicate double_import(Import initialImport, Import redundantImport, Module targetModule) {
  // Ensure distinct import statements and both are simple imports
  initialImport != redundantImport and
  is_simple_import(initialImport) and
  is_simple_import(redundantImport) and
  
  // Verify both imports reference identical modules
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = targetModule.getName() and
    secondModuleRef.getName() = targetModule.getName() and
    firstModuleRef = initialImport.getAName().getValue() and
    secondModuleRef = redundantImport.getAName().getValue()
  ) and
  
  // Confirm identical aliases are used for both imports
  initialImport.getAName().getAsname().(Name).getId() = 
  redundantImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope and positional constraints
  exists(Module commonScope |
    initialImport.getScope() = commonScope and
    redundantImport.getEnclosingModule() = commonScope and
    (
      // Redundant import is not in top-level scope OR
      redundantImport.getScope() != commonScope
      or
      // Initial import appears before redundant import in code
      initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Identify and report redundant module imports
from Import initialImport, Import redundantImport, Module targetModule
where double_import(initialImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()