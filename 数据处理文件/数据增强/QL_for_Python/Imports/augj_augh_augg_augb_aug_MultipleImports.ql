/**
 * @name Redundant module import detected
 * @description Multiple imports of the same module are redundant and decrease code readability
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
 * Determines if an import statement is a simple import without attribute access.
 * Simple imports only import the module itself without accessing specific attributes.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Identifies duplicate imports of the same module within the same or nested scopes.
 * 
 * @param primaryImport - The first occurrence of the import statement
 * @param duplicateImport - The redundant import statement
 * @param importedModule - The module that is imported multiple times
 */
predicate double_import(Import primaryImport, Import duplicateImport, Module importedModule) {
  // Ensure we're dealing with distinct import statements
  primaryImport != duplicateImport and
  
  // Both imports must be simple imports (without attribute access)
  is_simple_import(primaryImport) and
  is_simple_import(duplicateImport) and
  
  // Verify both imports reference the same module with identical aliases
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    // Both expressions reference the same target module
    firstModuleExpr.getName() = importedModule.getName() and
    secondModuleExpr.getName() = importedModule.getName() and
    
    // Connect the expressions to their respective import statements
    firstModuleExpr = primaryImport.getAName().getValue() and
    secondModuleExpr = duplicateImport.getAName().getValue() and
    
    // Ensure both imports use the same alias
    primaryImport.getAName().getAsname().(Name).getId() = 
    duplicateImport.getAName().getAsname().(Name).getId()
  ) and
  
  // Check scope relationship and ordering constraints
  exists(Module sharedScope |
    // Both imports are within the same module scope
    primaryImport.getScope() = sharedScope and
    duplicateImport.getEnclosingModule() = sharedScope and
    
    // Either the duplicate is in a nested scope OR the primary comes before the duplicate
    (
      duplicateImport.getScope() != sharedScope
      or
      primaryImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Query to find and report redundant module imports
from Import primaryImport, Import duplicateImport, Module importedModule
where double_import(primaryImport, duplicateImport, importedModule)
select duplicateImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  primaryImport, "on line " + primaryImport.getLocation().getStartLine().toString()