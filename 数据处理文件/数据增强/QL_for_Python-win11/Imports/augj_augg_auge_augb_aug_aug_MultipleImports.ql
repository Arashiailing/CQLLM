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
 * Determines if an import statement imports an entire module without accessing specific attributes.
 * Such imports bring in the complete module namespace without attribute-level selection.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Verifies that two imports reference the same module with consistent aliasing.
 * Ensures both imports target the identical module and maintain matching alias conventions.
 */
predicate same_module_with_consistent_alias(Import primaryImport, Import secondaryImport, Module targetModule) {
  exists(ImportExpr moduleExpr1, ImportExpr moduleExpr2 |
    moduleExpr1 = primaryImport.getAName().getValue() and
    moduleExpr2 = secondaryImport.getAName().getValue() and
    moduleExpr1.getName() = targetModule.getName() and
    moduleExpr2.getName() = targetModule.getName()
  ) and
  
  // Validate alias consistency between imports
  (if exists(primaryImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name alias1, Name alias2 |
       alias1 = primaryImport.getAName().getAsname() and
       alias2 = secondaryImport.getAName().getAsname() and
       alias1.getId() = alias2.getId()
     )
   else 
     // Neither import has an alias
     not exists(secondaryImport.getAName().getAsname())
  )
}

/**
 * Identifies redundant imports by comparing import statements within the same scope.
 * Checks for duplicate module imports considering scope hierarchy and code ordering.
 */
predicate is_redundant_import(Import primaryImport, Import secondaryImport, Module targetModule) {
  // Basic conditions: distinct simple imports
  primaryImport != secondaryImport and
  is_simple_import(primaryImport) and
  is_simple_import(secondaryImport) and
  
  // Verify both imports reference the same module with consistent aliasing
  same_module_with_consistent_alias(primaryImport, secondaryImport, targetModule) and
  
  // Validate scope containment and position relationships
  exists(Module enclosingModule |
    primaryImport.getScope() = enclosingModule and
    secondaryImport.getEnclosingModule() = enclosingModule and
    (
      // Either the secondary import is in a nested scope
      secondaryImport.getScope() != enclosingModule
      or
      // Or the primary import appears before the secondary one in code
      primaryImport.getAnEntryNode().dominates(secondaryImport.getAnEntryNode())
    )
  )
}

// Query to identify and report redundant imports
from Import primaryImport, Import secondaryImport, Module targetModule
where is_redundant_import(primaryImport, secondaryImport, targetModule)
select secondaryImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()