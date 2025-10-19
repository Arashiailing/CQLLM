/**
 * @name Module is imported more than once
 * @description Detects duplicate module imports within the same scope
 *              that unnecessarily increase code size and decrease maintainability.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Check if an import statement is simple (i.e., doesn't access module attributes)
predicate is_simple_import(Import importStatement) { 
  not exists(Attribute attr | importStatement.contains(attr)) 
}

// Identify pairs of duplicate imports within the same scope
predicate double_import(Import initialImport, Import duplicateImport, Module targetModule) {
  // Basic validation: imports must be distinct and both must be simple imports
  initialImport != duplicateImport and
  is_simple_import(initialImport) and
  is_simple_import(duplicateImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr firstModExpr, ImportExpr secondModExpr |
    firstModExpr = initialImport.getAName().getValue() and
    secondModExpr = duplicateImport.getAName().getValue() and
    firstModExpr.getName() = targetModule.getName() and
    secondModExpr.getName() = targetModule.getName()
  ) and
  
  // Ensure alias consistency between imports
  (if exists(initialImport.getAName().getAsname())
   then 
     // When both imports have aliases, they must match
     exists(Name firstAlias, Name secondAlias |
       firstAlias = initialImport.getAName().getAsname() and
       secondAlias = duplicateImport.getAName().getAsname() and
       firstAlias.getId() = secondAlias.getId()
     )
   else 
     // If the first import has no alias, the second shouldn't either
     not exists(duplicateImport.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module parentModule |
    // Both imports must be in the same parent module
    initialImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    
    // Position validation: either the duplicate is not in top-level scope
    // or the initial import appears before the duplicate
    (duplicateImport.getScope() != parentModule or
     initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode()))
  )
}

// Query to find and report redundant import statements
from Import initialImport, Import duplicateImport, Module targetModule
where double_import(initialImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()