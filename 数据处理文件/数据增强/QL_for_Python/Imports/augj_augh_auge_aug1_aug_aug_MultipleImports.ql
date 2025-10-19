/**
 * @name Module is imported more than once
 * @description Identifies instances where the same module is imported multiple times
 *              within the same scope. This redundancy unnecessarily increases code size
 *              and negatively impacts maintainability.
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
 * Determines if an import statement is a simple import.
 * A simple import is one that does not access module attributes directly.
 * For example, 'import module' is simple, while 'import module.attribute' is not.
 */
predicate isSimpleImport(Import importStmt) { 
  not exists(Attribute moduleAttr | importStmt.contains(moduleAttr)) 
}

/**
 * Identifies pairs of duplicate imports within the same scope.
 * This predicate checks if two imports refer to the same module, have consistent aliasing,
 * and are positioned appropriately within the same scope.
 */
predicate duplicateImport(Import primaryImport, Import duplicateImport, Module importedModule) {
  // Ensure we're dealing with two distinct import statements
  primaryImport != duplicateImport and
  
  // Both imports must be simple imports (no attribute access)
  isSimpleImport(primaryImport) and
  isSimpleImport(duplicateImport) and
  
  // Verify both imports reference the same target module
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    firstModuleExpr = primaryImport.getAName().getValue() and
    secondModuleExpr = duplicateImport.getAName().getValue() and
    firstModuleExpr.getName() = importedModule.getName() and
    secondModuleExpr.getName() = importedModule.getName()
  ) and
  
  // Check alias consistency between the two imports
  (if exists(primaryImport.getAName().getAsname())
   then 
     // If the primary import has an alias, the duplicate must have the same alias
     exists(Name primaryAlias, Name duplicateAlias |
       primaryAlias = primaryImport.getAName().getAsname() and
       duplicateAlias = duplicateImport.getAName().getAsname() and
       primaryAlias.getId() = duplicateAlias.getId()
     )
   else 
     // If the primary import has no alias, the duplicate should also have no alias
     not exists(duplicateImport.getAName().getAsname())
  ) and
  
  // Validate scope and positioning constraints
  exists(Module enclosingModule |
    // Both imports must be in the same parent module
    primaryImport.getScope() = enclosingModule and
    duplicateImport.getEnclosingModule() = enclosingModule and
    
    // Either the duplicate is not in the top-level scope
    // or the primary import comes before the duplicate
    (duplicateImport.getScope() != enclosingModule or
     primaryImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode()))
  )
}

// Main query to detect and report redundant import statements
from Import primaryImport, Import duplicateImport, Module importedModule
where duplicateImport(primaryImport, duplicateImport, importedModule)
select duplicateImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()