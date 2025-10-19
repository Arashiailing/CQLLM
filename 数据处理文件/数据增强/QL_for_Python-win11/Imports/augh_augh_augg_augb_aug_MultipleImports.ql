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
 * Determines if an import statement is a simple module import without attribute access.
 * Simple imports reference only the module itself, not its members.
 */
predicate is_simple_import(Import importStmt) { 
  not exists(Attribute attr | importStmt.contains(attr)) 
}

/**
 * Identifies redundant imports of the same module within related scopes.
 * 
 * @param firstImport - The initial import statement
 * @param secondImport - The redundant import statement
 * @param targetModule - The module being imported multiple times
 */
predicate double_import(Import firstImport, Import secondImport, Module targetModule) {
  // Validate distinct simple imports
  firstImport != secondImport and
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Extract module references and validate identical targets
  exists(ImportExpr firstModRef, ImportExpr secondModRef |
    firstModRef.getName() = targetModule.getName() and
    secondModRef.getName() = targetModule.getName() and
    firstModRef = firstImport.getAName().getValue() and
    secondModRef = secondImport.getAName().getValue() and
    
    // Ensure consistent aliasing between imports
    firstImport.getAName().getAsname().(Name).getId() = 
    secondImport.getAName().getAsname().(Name).getId()
  ) and
  
  // Analyze scope relationships and code ordering
  exists(Module sharedScope |
    firstImport.getScope() = sharedScope and
    secondImport.getEnclosingModule() = sharedScope and
    (
      // Case 1: Redundant import in nested scope
      secondImport.getScope() != sharedScope
      or
      // Case 2: Sequential imports in same scope (first dominates second)
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Report redundant module imports with location context
from Import firstImport, Import secondImport, Module targetModule
where double_import(firstImport, secondImport, targetModule)
select secondImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()