/**
 * @name Module is imported more than once
 * @description Importing a module a second time has no effect and impairs readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Check if an import statement is a simple import (without attribute access)
predicate is_simple_import(Import importStatement) { 
  not exists(Attribute attr | importStatement.contains(attr)) 
}

// Detect duplicate imports within the same scope
predicate double_import(Import firstImportStmt, Import secondImportStmt, Module importedModule) {
  // Basic conditions: distinct simple imports
  firstImportStmt != secondImportStmt and
  is_simple_import(firstImportStmt) and
  is_simple_import(secondImportStmt) and
  
  // Module reference conditions: both imports reference the same module
  exists(ImportExpr firstModuleRef, ImportExpr secondModuleRef |
    firstModuleRef.getName() = importedModule.getName() and
    secondModuleRef.getName() = importedModule.getName() and
    firstModuleRef = firstImportStmt.getAName().getValue() and
    secondModuleRef = secondImportStmt.getAName().getValue()
  ) and
  
  // Alias condition: identical aliases are used
  firstImportStmt.getAName().getAsname().(Name).getId() = 
  secondImportStmt.getAName().getAsname().(Name).getId() and
  
  // Scope and position conditions
  exists(Module enclosingScope |
    firstImportStmt.getScope() = enclosingScope and
    secondImportStmt.getEnclosingModule() = enclosingScope and
    (
      // Either duplicate is not in top-level scope
      secondImportStmt.getScope() != enclosingScope
      or
      // Or first import appears before duplicate in code
      firstImportStmt.getAnEntryNode().dominates(secondImportStmt.getAnEntryNode())
    )
  )
}

// Identify and report duplicate imports
from Import firstImportStmt, Import secondImportStmt, Module importedModule
where double_import(firstImportStmt, secondImportStmt, importedModule)
select secondImportStmt,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImportStmt, "on line " + firstImportStmt.getLocation().getStartLine().toString()