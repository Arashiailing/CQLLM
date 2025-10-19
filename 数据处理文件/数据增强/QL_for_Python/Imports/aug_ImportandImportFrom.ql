/**
 * @name Module imported using both 'import' and 'import from' statements
 * @description Detects modules imported using both direct import and from-import statements
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision very-high
 * @id py/import-and-import-from
 */

// Import Python analysis library for code examination
import python

// Predicate to identify modules imported via both import styles
predicate dualImportStyle(Import directImport, Import fromImport, Module targetModule) {
  // Verify both imports belong to the same enclosing module
  directImport.getEnclosingModule() = fromImport.getEnclosingModule() and
  // Extract import expressions and validate module name consistency
  exists(ImportExpr directExpr, ImportExpr fromExpr, ImportMember importedMember |
    // Direct import expression retrieval
    directExpr = directImport.getAName().getValue() and 
    // From-import member extraction
    importedMember = fromImport.getAName().getValue() and 
    // Module expression from from-import
    fromExpr = importedMember.getModule()
  |
    // Confirm both expressions reference the target module
    directExpr.getName() = targetModule.getName() and 
    fromExpr.getName() = targetModule.getName()
  )
}

// Query execution with filtered imports and modules
from Import directImport, Import fromImport, Module targetModule
// Apply predicate to identify dual import patterns
where dualImportStyle(directImport, fromImport, targetModule)
// Generate alert for the first import occurrence
select directImport, "Module '" + targetModule.getName() + "' uses both 'import' and 'import from' statements."