/**
 * @name Duplicate module import detected
 * @description Multiple imports of the same module are unnecessary and reduce code clarity
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
 * Simple imports are those that don't reference module attributes directly.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Finds duplicate imports of the same module within identical or nested scopes.
 * 
 * @param firstImport - The original import statement
 * @param duplicateImport - The redundant import statement
 * @param importedModule - The module that is imported multiple times
 */
predicate double_import(Import firstImport, Import duplicateImport, Module importedModule) {
  // Ensure imports are distinct and both are simple imports
  firstImport != duplicateImport and
  is_simple_import(firstImport) and
  is_simple_import(duplicateImport) and
  
  // Check that both imports reference the same module with the same alias
  exists(ImportExpr moduleRef1, ImportExpr moduleRef2 |
    moduleRef1.getName() = importedModule.getName() and
    moduleRef2.getName() = importedModule.getName() and
    moduleRef1 = firstImport.getAName().getValue() and
    moduleRef2 = duplicateImport.getAName().getValue() and
    firstImport.getAName().getAsname().(Name).getId() = 
    duplicateImport.getAName().getAsname().(Name).getId()
  ) and
  
  // Validate scope and ordering constraints
  exists(Module sharedScope |
    firstImport.getScope() = sharedScope and
    duplicateImport.getEnclosingModule() = sharedScope and
    (
      // Duplicate import is in a nested scope OR
      duplicateImport.getScope() != sharedScope
      or
      // First import appears before duplicate import in the code
      firstImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Find and report duplicate module imports
from Import firstImport, Import duplicateImport, Module importedModule
where double_import(firstImport, duplicateImport, importedModule)
select duplicateImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()