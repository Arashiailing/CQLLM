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
predicate hasMixedImportStyles(Import directStyleImport, Import fromStyleImport, Module targetModule) {
  // Verify both imports belong to the same enclosing module
  directStyleImport.getEnclosingModule() = fromStyleImport.getEnclosingModule() and
  // Extract import expressions and validate module name consistency
  exists(ImportExpr directImportExpr, ImportExpr fromImportExpr, ImportMember fromImportMember |
    // Direct import expression retrieval
    directImportExpr = directStyleImport.getAName().getValue() and 
    // From-import member extraction
    fromImportMember = fromStyleImport.getAName().getValue() and 
    // Module expression from from-import
    fromImportExpr = fromImportMember.getModule()
  |
    // Confirm both expressions reference the target module
    directImportExpr.getName() = targetModule.getName() and 
    fromImportExpr.getName() = targetModule.getName()
  )
}

// Query execution with filtered imports and modules
from Import directStyleImport, Import fromStyleImport, Module targetModule
// Apply predicate to identify dual import patterns
where hasMixedImportStyles(directStyleImport, fromStyleImport, targetModule)
// Generate alert for the first import occurrence
select directStyleImport, "Module '" + targetModule.getName() + "' uses both 'import' and 'import from' statements."