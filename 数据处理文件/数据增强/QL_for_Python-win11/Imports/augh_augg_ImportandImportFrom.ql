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

/**
 * Predicate to identify modules imported via both import styles:
 * - Direct import: import module
 * - From import: from module import something
 */
predicate dualImportStyles(Import primaryImport, Import secondaryImport, Module importedModule) {
  // Ensure both imports are within the same source file
  primaryImport.getEnclosingModule() = secondaryImport.getEnclosingModule() and
  
  // Analyze import expressions to detect dual import patterns
  exists(ImportExpr directImportExpr, ImportExpr fromImportExpr, ImportMember memberImport |
    // Link primary import to direct import expression
    directImportExpr = primaryImport.getAName().getValue() and 
    // Link secondary import to member expression
    memberImport = secondaryImport.getAName().getValue() and 
    // Get the module from which the member is imported
    fromImportExpr = memberImport.getModule()
  |
    // Verify both expressions reference the same target module
    directImportExpr.getName() = importedModule.getName() and 
    fromImportExpr.getName() = importedModule.getName()
  )
}

// Find all import pairs that demonstrate dual import styles for the same module
from Import primaryImport, Import secondaryImport, Module importedModule
where dualImportStyles(primaryImport, secondaryImport, importedModule)
// Report the primary import instance with a descriptive message
select primaryImport, "Module '" + importedModule.getName() + "' uses both 'import' and 'import from' statements."