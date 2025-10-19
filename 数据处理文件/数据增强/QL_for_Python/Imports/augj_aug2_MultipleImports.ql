/**
 * @name Module is imported more than once
 * @description Identifies redundant module imports that impair code readability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Predicate to check if an import statement is a simple import (without attribute access)
predicate isSimpleImport(Import imp) { not exists(Attribute a | imp.contains(a)) }

// Predicate to identify duplicate imports within the same module scope
predicate hasDuplicateImport(Import mainImport, Import duplicateImport, Module targetModule) {
  // Ensure imports are distinct and both are simple imports
  mainImport != duplicateImport and
  isSimpleImport(mainImport) and
  isSimpleImport(duplicateImport) and
  
  // Verify both imports reference the same target module
  exists(ImportExpr mainExpr, ImportExpr dupExpr |
    mainExpr.getName() = targetModule.getName() and
    dupExpr.getName() = targetModule.getName() and
    mainExpr = mainImport.getAName().getValue() and
    dupExpr = duplicateImport.getAName().getValue()
  ) and
  
  // Confirm both imports use identical aliases
  mainImport.getAName().getAsname().(Name).getId() = duplicateImport.getAName().getAsname().(Name).getId() and
  
  // Check scope conditions: both imports in same module with either:
  // - Duplicate import in nested scope, OR
  // - Main import appears before duplicate in source order
  exists(Module parentModule |
    mainImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      duplicateImport.getScope() != parentModule or
      mainImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Query to detect and report redundant module imports
from Import mainImport, Import duplicateImport, Module targetModule
where hasDuplicateImport(mainImport, duplicateImport, targetModule)
select duplicateImport,
  "This import of module " + targetModule.getName() + " is redundant, as it was previously imported $@.",
  mainImport, "on line " + mainImport.getLocation().getStartLine().toString()