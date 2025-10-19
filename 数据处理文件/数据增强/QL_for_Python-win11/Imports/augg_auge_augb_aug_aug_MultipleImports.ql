/**
 * @name Module is imported more than once
 * @description Identifies redundant module imports where the same module is imported 
 *              multiple times within the same scope, which is functionally unnecessary 
 *              and reduces code clarity.
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
 * Checks if an import statement is a simple import (without attribute access).
 * Simple imports bring in the entire module without accessing specific attributes.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Determines if two imports reference the same module with consistent aliasing.
 */
predicate same_module_with_consistent_alias(Import import1, Import import2, Module targetModule) {
  exists(ImportExpr moduleRef1, ImportExpr moduleRef2 |
    moduleRef1 = import1.getAName().getValue() and
    moduleRef2 = import2.getAName().getValue() and
    moduleRef1.getName() = targetModule.getName() and
    moduleRef2.getName() = targetModule.getName()
  ) and
  
  // Verify alias consistency between imports
  (if exists(import1.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name alias1, Name alias2 |
       alias1 = import1.getAName().getAsname() and
       alias2 = import2.getAName().getAsname() and
       alias1.getId() = alias2.getId()
     )
   else 
     // Neither import has an alias
     not exists(import2.getAName().getAsname())
  )
}

/**
 * Checks if one import is redundant relative to another within the same scope.
 */
predicate is_redundant_import(Import firstImport, Import secondImport, Module targetModule) {
  // Basic conditions: distinct simple imports
  firstImport != secondImport and
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Check if both imports reference the same module with consistent aliasing
  same_module_with_consistent_alias(firstImport, secondImport, targetModule) and
  
  // Validate scope and position relationships
  exists(Module parentModule |
    firstImport.getScope() = parentModule and
    secondImport.getEnclosingModule() = parentModule and
    (
      // Either the second import is in a nested scope
      secondImport.getScope() != parentModule
      or
      // Or the first import appears before the second one in the code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

/**
 * Finds instances where a module is imported more than once in the same scope.
 */
predicate double_import(Import firstImport, Import secondImport, Module targetModule) {
  is_redundant_import(firstImport, secondImport, targetModule)
}

// Query to identify and report redundant imports
from Import firstImport, Import secondImport, Module targetModule
where double_import(firstImport, secondImport, targetModule)
select secondImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()