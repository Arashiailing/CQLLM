/**
 * @name Module is imported more than once
 * @description Detects redundant module imports where the same module is imported 
 *              multiple times within the same scope, which serves no functional purpose 
 *              and degrades code readability.
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
 * Determines if an import statement is a simple import (without attribute access).
 * Simple imports import the entire module without accessing specific attributes.
 */
predicate is_simple_import(Import importStatement) { 
  not exists(Attribute attr | importStatement.contains(attr)) 
}

/**
 * Identifies when a module is imported more than once in the same scope.
 * This predicate checks for duplicate imports of the same module with the same alias.
 */
predicate double_import(Import originalImport, Import redundantImport, Module importedModule) {
  // Basic conditions: distinct simple imports
  originalImport != redundantImport and
  is_simple_import(originalImport) and
  is_simple_import(redundantImport) and
  
  // Check if both imports reference the same target module
  exists(ImportExpr originalModuleRef, ImportExpr redundantModuleRef |
    originalModuleRef = originalImport.getAName().getValue() and
    redundantModuleRef = redundantImport.getAName().getValue() and
    originalModuleRef.getName() = importedModule.getName() and
    redundantModuleRef.getName() = importedModule.getName()
  ) and
  
  // Verify alias consistency between imports
  (if exists(originalImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name originalAlias, Name redundantAlias |
       originalAlias = originalImport.getAName().getAsname() and
       redundantAlias = redundantImport.getAName().getAsname() and
       originalAlias.getId() = redundantAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(redundantImport.getAName().getAsname())
  ) and
  
  // Validate scope and position relationships
  exists(Module containingModule |
    originalImport.getScope() = containingModule and
    redundantImport.getEnclosingModule() = containingModule and
    (
      // Either the redundant import is in a nested scope
      redundantImport.getScope() != containingModule
      or
      // Or the original import appears before the redundant one in the code
      originalImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant imports
from Import originalImport, Import redundantImport, Module importedModule
where double_import(originalImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  originalImport, "on line " + originalImport.getLocation().getStartLine().toString()