/**
 * @name Module is imported more than once
 * @description Detects when a module is imported multiple times within the same scope,
 *              which is redundant since subsequent imports have no effect
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
 * Determines if an import statement is a "simple" import,
 * meaning it doesn't access any attributes of the imported module.
 * Simple imports are those that just import the module without
 * accessing specific functions, classes, or variables from it.
 * 
 * @param importStmt - The import statement to check
 */
predicate is_simple_import(Import importStmt) { 
  // An import is considered simple if it doesn't contain any attribute references
  not exists(Attribute attributeRef | importStmt.contains(attributeRef)) 
}

/**
 * Identifies cases where the same module is imported more than once
 * within the same scope, making the second import redundant.
 * 
 * @param firstImport - The first occurrence of the import
 * @param secondImport - The redundant duplicate import statement
 * @param importedModule - The module being imported redundantly
 */
predicate double_import(Import firstImport, Import secondImport, Module importedModule) {
  // Basic validation: ensure we're dealing with two different import statements
  firstImport != secondImport and
  
  // Both imports must be simple imports (without attribute access)
  is_simple_import(firstImport) and
  is_simple_import(secondImport) and
  
  // Check if both imports reference the same module
  exists(ImportExpr firstModuleExpr, ImportExpr secondModuleExpr |
    // Verify the module names match
    firstModuleExpr.getName() = importedModule.getName() and
    secondModuleExpr.getName() = importedModule.getName() and
    
    // Connect the module expressions to their respective import statements
    firstModuleExpr = firstImport.getAName().getValue() and
    secondModuleExpr = secondImport.getAName().getValue()
  ) and
  
  // Ensure the same alias is used for both imports (if any)
  firstImport.getAName().getAsname().(Name).getId() = 
  secondImport.getAName().getAsname().(Name).getId() and
  
  // Validate scope and positional constraints
  exists(Module sharedScope |
    // Both imports must be within the same module scope
    firstImport.getScope() = sharedScope and
    secondImport.getEnclosingModule() = sharedScope and
    
    // Check if the second import is redundant based on scope or position
    (
      // Case 1: The second import is not in the top-level scope
      secondImport.getScope() != sharedScope
      or
      // Case 2: The first import appears before the second import in the code
      firstImport.getAnEntryNode().dominates(secondImport.getAnEntryNode())
    )
  )
}

// Query to find and report redundant module imports
from Import firstImport, Import secondImport, Module importedModule
where double_import(firstImport, secondImport, importedModule)
select secondImport,
  "This import of module " + importedModule.getName() + " is redundant, as it was previously imported $@.",
  firstImport, "on line " + firstImport.getLocation().getStartLine().toString()