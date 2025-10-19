/**
 * @name Redundant module import detected
 * @description Multiple imports of the same module are redundant and decrease code readability
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
 * Checks whether an import statement is a simple import without attribute access.
 * Simple imports don't directly reference module attributes.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Identifies redundant imports of the same module in identical or nested scopes.
 * 
 * @param originalImport - The initial import statement
 * @param redundantImport - The duplicate import statement
 * @param targetModule - The module being imported multiple times
 */
predicate double_import(Import originalImport, Import redundantImport, Module targetModule) {
  // Validate distinct imports and simple import types
  originalImport != redundantImport and
  is_simple_import(originalImport) and
  is_simple_import(redundantImport) and
  
  // Confirm identical module references and matching aliases
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = targetModule.getName() and
    secondModuleRef.getName() = targetModule.getName() and
    firstModuleRef = originalImport.getAName().getValue() and
    secondModuleRef = redundantImport.getAName().getValue() and
    originalImport.getAName().getAsname().(Name).getId() = 
    redundantImport.getAName().getAsname().(Name).getId()
  ) and
  
  // Establish scope relationship and ordering constraints
  exists(Module commonScope |
    originalImport.getScope() = commonScope and
    redundantImport.getEnclosingModule() = commonScope and
    (
      // Redundant import exists in nested scope OR
      redundantImport.getScope() != commonScope
      or
      // Original import precedes redundant import in code
      originalImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Identify and report redundant module imports
from Import originalImport, Import redundantImport, Module targetModule
where double_import(originalImport, redundantImport, targetModule)
select redundantImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  originalImport, "on line " + originalImport.getLocation().getStartLine().toString()