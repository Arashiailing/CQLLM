/**
 * @name Module is imported with 'import' and 'import from'
 * @description A module is imported using both "import" and "import from" statements
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision very-high
 * @id py/import-and-import-from
 */

// Import Python analysis library for code processing
import python

// Define predicate to identify modules imported via both import styles
predicate dualImportStyles(Import firstImport, Import secondImport, Module targetModule) {
  // Verify both imports belong to the same enclosing module
  firstImport.getEnclosingModule() = secondImport.getEnclosingModule() and
  // Check for matching import expressions and members
  exists(ImportExpr baseImport, ImportExpr derivedImport, ImportMember importedMember |
    // Associate first import with base expression
    baseImport = firstImport.getAName().getValue() and 
    // Associate second import with member expression
    importedMember = secondImport.getAName().getValue() and 
    derivedImport = importedMember.getModule()
  |
    // Confirm both expressions reference the target module
    baseImport.getName() = targetModule.getName() and 
    derivedImport.getName() = targetModule.getName()
  )
}

// Query all import statements and modules
from Import firstImport, Import secondImport, Module targetModule
// Filter imports using the dual-style predicate
where dualImportStyles(firstImport, secondImport, targetModule)
// Generate alert for the first import instance
select firstImport, "Module '" + targetModule.getName() + "' uses both 'import' and 'import from' statements."