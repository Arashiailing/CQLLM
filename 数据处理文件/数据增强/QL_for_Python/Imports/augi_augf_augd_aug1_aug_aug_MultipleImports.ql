/**
 * @name Module is imported more than once
 * @description Identifies redundant imports where the same module is imported multiple times
 *              within the same scope, which is functionally unnecessary and reduces code clarity.
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Checks if an import statement is simple (without any attribute access)
predicate is_simple_import(Import importDeclaration) { 
  not exists(Attribute attr | importDeclaration.contains(attr)) 
}

// Finds duplicate imports within the same scope
predicate duplicate_import_found(Import initialImport, Import redundantImport, Module importedModule) {
  // Basic import validation
  initialImport != redundantImport and
  is_simple_import(initialImport) and
  is_simple_import(redundantImport) and
  
  // Module reference verification
  exists(ImportExpr initialImportExpr, ImportExpr redundantImportExpr |
    initialImportExpr = initialImport.getAName().getValue() and
    redundantImportExpr = redundantImport.getAName().getValue() and
    initialImportExpr.getName() = importedModule.getName() and
    redundantImportExpr.getName() = importedModule.getName()
  ) and
  
  // Alias consistency check
  (if exists(initialImport.getAName().getAsname())
   then 
     // Both imports have aliases - ensure they match
     exists(Name initialAlias, Name redundantAlias |
       initialAlias = initialImport.getAName().getAsname() and
       redundantAlias = redundantImport.getAName().getAsname() and
       initialAlias.getId() = redundantAlias.getId()
     )
   else 
     // Neither import has an alias
     not exists(redundantImport.getAName().getAsname())
  ) and
  
  // Scope and positioning validation
  exists(Module enclosingModule |
    // Both imports must be in the same parent module
    initialImport.getEnclosingModule() = enclosingModule and
    redundantImport.getEnclosingModule() = enclosingModule and
    
    // Either the duplicate is not in top-level scope
    // or the first import appears before the second
    (redundantImport.getScope() != enclosingModule or
     initialImport.getAnEntryNode().dominates(redundantImport.getAnEntryNode()))
  )
}

// Report redundant imports
from Import initialImport, Import redundantImport, Module importedModule
where duplicate_import_found(initialImport, redundantImport, importedModule)
select redundantImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()