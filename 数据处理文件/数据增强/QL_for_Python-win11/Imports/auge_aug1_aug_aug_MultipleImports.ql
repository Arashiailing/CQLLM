/**
 * @name Module is imported more than once
 * @description Identifies redundant module imports that occur multiple times
 *              within the same scope, which unnecessarily bloats the code
 *              and reduces maintainability.
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
predicate is_simple_import(Import impStmt) { 
  not exists(Attribute attr | impStmt.contains(attr)) 
}

// Identify pairs of duplicate imports within the same scope
predicate double_import(Import firstImport, Import repeatedImport, Module importedModule) {
  // Ensure imports are distinct and both are simple imports
  firstImport != repeatedImport and
  is_simple_import(firstImport) and
  is_simple_import(repeatedImport) and
  
  // Verify both imports reference the same module
  exists(ImportExpr modExpr1, ImportExpr modExpr2 |
    modExpr1 = firstImport.getAName().getValue() and
    modExpr2 = repeatedImport.getAName().getValue() and
    modExpr1.getName() = importedModule.getName() and
    modExpr2.getName() = importedModule.getName()
  ) and
  
  // Check alias consistency between imports
  (if exists(firstImport.getAName().getAsname())
   then 
     // Both imports have aliases - they must match
     exists(Name alias1, Name alias2 |
       alias1 = firstImport.getAName().getAsname() and
       alias2 = repeatedImport.getAName().getAsname() and
       alias1.getId() = alias2.getId()
     )
   else 
     // Neither import should have an alias
     not exists(repeatedImport.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module containerModule |
    // Both imports must be in the same parent module
    firstImport.getScope() = containerModule and
    repeatedImport.getEnclosingModule() = containerModule and
    
    // Either the duplicate is not in top-level scope
    // or the initial import appears before the duplicate
    (repeatedImport.getScope() != containerModule or
     firstImport.getAnEntryNode().dominates(repeatedImport.getAnEntryNode()))
  )
}

// Query to find and report redundant import statements
from Import firstImport, Import repeatedImport, Module importedModule
where double_import(firstImport, repeatedImport, importedModule)
select repeatedImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()