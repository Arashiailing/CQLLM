/**
 * @name Redundant module import detection
 * @description Identifies duplicate module imports that reduce code maintainability
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/repeated-import
 */

import python

// Determines if import is simple (without attribute access)
predicate isSimpleImport(Import importStatement) { 
  not exists(Attribute attr | importStatement.contains(attr)) 
}

// Identifies duplicate imports for same module
predicate findDuplicateImports(Import initialImport, Import duplicateImport, Module targetModule) {
  initialImport != duplicateImport and
  isSimpleImport(initialImport) and
  isSimpleImport(duplicateImport) and
  // Verify both imports reference same target module
  exists(ImportExpr initImportExpr, ImportExpr dupImportExpr |
    initImportExpr.getName() = targetModule.getName() and
    dupImportExpr.getName() = targetModule.getName() and
    initImportExpr = initialImport.getAName().getValue() and
    dupImportExpr = duplicateImport.getAName().getValue()
  ) and
  // Confirm identical alias usage
  initialImport.getAName().getAsname().(Name).getId() = duplicateImport.getAName().getAsname().(Name).getId() and
  // Validate import location relationships
  exists(Module parentModule |
    initialImport.getScope() = parentModule and
    duplicateImport.getEnclosingModule() = parentModule and
    (
      // Duplicate is nested within function/class scope
      duplicateImport.getScope() != parentModule
      or
      // Initial import appears earlier in code
      initialImport.getAnEntryNode().dominates(duplicateImport.getAnEntryNode())
    )
  )
}

// Locate and report all duplicate import instances
from Import initialImport, Import duplicateImport, Module targetModule
where findDuplicateImports(initialImport, duplicateImport, targetModule)
select duplicateImport,
  "Redundant import of module " + targetModule.getName() + " previously imported $@.",
  initialImport, "on line " + initialImport.getLocation().getStartLine().toString()