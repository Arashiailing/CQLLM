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

import python

// Predicate identifying modules with mixed import styles
predicate mixedImportStyle(Import plainImport, Import fromImport, Module importedModule) {
  // Ensure both imports originate from the same source module
  plainImport.getEnclosingModule() = fromImport.getEnclosingModule() and
  // Extract and validate import expressions
  exists(ImportExpr plainExpr, ImportMember fromMember, ImportExpr fromExpr |
    // Resolve direct import expression
    plainExpr = plainImport.getAName().getValue() and 
    // Resolve from-import member
    fromMember = fromImport.getAName().getValue() and 
    // Resolve module expression from from-import
    fromExpr = fromMember.getModule() and
    // Validate both expressions reference the same target module
    plainExpr.getName() = importedModule.getName() and 
    fromExpr.getName() = importedModule.getName()
  )
}

// Query execution detecting inconsistent import patterns
from Import plainImport, Import fromImport, Module importedModule
// Apply predicate to identify conflicting import styles
where mixedImportStyle(plainImport, fromImport, importedModule)
// Generate alert for the primary import statement
select plainImport, "Module '" + importedModule.getName() + "' uses both 'import' and 'import from' statements."