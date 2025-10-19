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
 * Helper predicate to identify simple imports without attribute access.
 * Simple imports are those that directly import a module without accessing its attributes.
 */
predicate is_simple_import(Import imp) { 
  not exists(Attribute attr | imp.contains(attr)) 
}

/**
 * Core predicate to detect duplicate imports with same module and alias.
 * Identifies when a module is imported multiple times with identical aliasing,
 * either in the same scope or in nested scopes.
 */
predicate duplicate_import_found(Import initialImport, Import repeatedImport, Module targetModule) {
  // Basic validation: imports must be distinct and both must be simple imports
  initialImport != repeatedImport and
  is_simple_import(initialImport) and
  is_simple_import(repeatedImport) and
  
  // Verify both imports reference the same target module
  exists(ImportExpr initialExpr, ImportExpr repeatedExpr |
    initialExpr.getName() = targetModule.getName() and
    repeatedExpr.getName() = targetModule.getName() and
    initialExpr = initialImport.getAName().getValue() and
    repeatedExpr = repeatedImport.getAName().getValue()
  ) and
  
  // Confirm identical aliases are used in both imports
  initialImport.getAName().getAsname().(Name).getId() = 
  repeatedImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope relationships and positioning
  exists(Module containerModule |
    // Both imports belong to the same container module
    initialImport.getScope() = containerModule and
    repeatedImport.getEnclosingModule() = containerModule and
    (
      // Case 1: Repeated import is in a nested scope
      repeatedImport.getScope() != containerModule
      or
      // Case 2: Initial import appears before repeated import in same scope
      initialImport.getAnEntryNode().dominates(repeatedImport.getAnEntryNode())
    )
  )
}

/**
 * Main query to identify and report redundant module imports.
 * Locates modules imported multiple times and reports the redundant import
 * with a reference to the original import location.
 */
from Import originalImport, Import redundantImport, Module importedModule
where duplicate_import_found(originalImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  originalImport, "on line " + originalImport.getLocation().getStartLine().toString()