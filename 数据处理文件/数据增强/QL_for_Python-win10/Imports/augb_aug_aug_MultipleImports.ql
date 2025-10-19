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

// Predicate to identify imports without attribute access
predicate is_simple_import(Import importDeclaration) { 
  not exists(Attribute attr | importDeclaration.contains(attr)) 
}

// Predicate to identify duplicate imports in same scope
predicate double_import(Import initialImport, Import duplicateImport, Module targetModule) {
  // Basic conditions: distinct simple imports
  initialImport != duplicateImport and
  is_simple_import(initialImport) and
  is_simple_import(duplicateImport) and
  
  // Module reference equivalence check
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef = initialImport.getAName().getValue() and
    secondModuleRef = duplicateImport.getAName().getValue() and
    firstModuleRef.getName() = targetModule.getName() and
    secondModuleRef.getName() = targetModule.getName()
  ) and
  
  // Alias consistency verification
  (if exists(initialImport.getAName().getAsname())
   then 
     // Both imports have aliases - compare them
     exists(Name firstAlias, Name secondAlias |
       firstAlias = initialImport.getAName().getAsname() and
       secondAlias = duplicateImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(duplicateImport.getAName().getAsname())
  ) and
  
  // Scope and position validation
  exists(Module parentModule |
    initialImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Duplicate is in nested scope OR
      duplicateImport.getScope() != parentModule
      or
      // Initial import precedes duplicate in code
      initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant imports
from Import initialImport, Import duplicateImport, Module targetModule
where double_import(initialImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()