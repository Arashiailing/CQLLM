/**
 * @name Module is imported more than once
 * @description Detects redundant duplicate imports of the same module within the same scope
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate identifying imports without attribute access operations
predicate is_simple_import(Import importNode) { 
  not exists(Attribute attr | importNode.contains(attr)) 
}

// Predicate detecting duplicate imports with identical module references and aliases
predicate double_import(Import initialImport, Import duplicateImport, Module targetModule) {
  // Verify distinct import nodes and simple import structure
  initialImport != duplicateImport and
  is_simple_import(initialImport) and
  is_simple_import(duplicateImport) and
  
  // Confirm both imports reference identical module
  exists(ImportExpr initialModuleRef, ImportExpr duplicateModuleRef |
    initialModuleRef.getName() = targetModule.getName() and
    duplicateModuleRef.getName() = targetModule.getName() and
    initialModuleRef = initialImport.getAName().getValue() and
    duplicateModuleRef = duplicateImport.getAName().getValue()
  ) and
  
  // Validate matching alias usage
  initialImport.getAName().getAsname().(Name).getId() = 
  duplicateImport.getAName().getAsname().(Name).getId() and
  
  // Check scope containment and positioning constraints
  exists(Module parentModule |
    initialImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Either duplicate is in nested scope (not top-level)
      duplicateImport.getScope() != parentModule
      or
      // Or initial import appears before duplicate in code
      initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant duplicate imports
from Import initialImport, Import duplicateImport, Module targetModule
where double_import(initialImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()