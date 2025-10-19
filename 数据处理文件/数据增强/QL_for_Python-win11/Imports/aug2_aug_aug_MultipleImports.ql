/**
 * @name Module is imported more than once
 * @description Identifies redundant module imports where a module is imported multiple times
 *              within the same scope, which has no functional effect and reduces code clarity.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate to identify imports that don't access module attributes
predicate is_simple_import(Import importDeclaration) { 
  not exists(Attribute attr | importDeclaration.contains(attr)) 
}

// Predicate to detect duplicate imports within the same scope
predicate double_import(Import initialImport, Import duplicateImport, Module importedModule) {
  // Ensure imports are distinct and simple (no attribute access)
  initialImport != duplicateImport and
  is_simple_import(initialImport) and
  is_simple_import(duplicateImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef = initialImport.getAName().getValue() and
    secondModuleRef = duplicateImport.getAName().getValue() and
    firstModuleRef.getName() = importedModule.getName() and
    secondModuleRef.getName() = importedModule.getName()
  ) and
  
  // Confirm identical aliases are used (including no alias case)
  (if exists(initialImport.getAName().getAsname())
   then 
     // Both imports have aliases - compare alias names
     exists(Name firstAlias, Name secondAlias |
       firstAlias = initialImport.getAName().getAsname() and
       secondAlias = duplicateImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(duplicateImport.getAName().getAsname())
  ) and
  
  // Check scope and positioning constraints
  exists(Scope sharedScope |
    initialImport.getScope() = sharedScope and
    duplicateImport.getScope() = sharedScope and
    (
      // Duplicate is not in top-level scope OR
      duplicateImport.getScope() != sharedScope.getEnclosingModule()
      or
      // First import appears before duplicate in code
      initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Identify and report duplicate imports
from Import initialImport, Import duplicateImport, Module importedModule
where double_import(initialImport, duplicateImport, importedModule)
select duplicateImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()