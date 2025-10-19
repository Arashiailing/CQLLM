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

// Predicate identifying modules with mixed import styles
predicate hasMixedImportStyles(Import directImport, Import fromImport, Module targetModule) {
  // Ensure both imports originate from the same source module
  directImport.getEnclosingModule() = fromImport.getEnclosingModule() and
  // Extract and validate import expressions for both styles
  exists(ImportExpr directExpr, ImportExpr fromExpr, ImportMember fromMember |
    // Retrieve direct import expression
    directExpr = directImport.getAName().getValue() and 
    // Extract from-import member details
    fromMember = fromImport.getAName().getValue() and 
    // Get module expression from from-import
    fromExpr = fromMember.getModule()
  |
    // Verify both expressions reference the same target module
    directExpr.getName() = targetModule.getName() and 
    fromExpr.getName() = targetModule.getName()
  )
}

// Identify modules with dual import patterns
from Import directImport, Import fromImport, Module targetModule
// Apply predicate to detect mixed import styles
where hasMixedImportStyles(directImport, fromImport, targetModule)
// Generate alert message for the first occurrence
select directImport, "Module '" + targetModule.getName() + "' uses both 'import' and 'import from' statements."