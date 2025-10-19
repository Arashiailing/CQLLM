/**
 * @name Import shadowed by loop variable
 * @description Identifies situations where a loop variable's name clashes with an imported module alias,
 *              which may lead to confusion or errors by hiding the imported identifier.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import Python analysis library for examining Python code structures
import python

// Detect loop variables that shadow imported module aliases, potentially causing identifier confusion
from Variable iterationVar, Name varDefNode
where 
  // Confirm the variable is used as a loop iteration target in a For statement
  exists(For forLoop | varDefNode = forLoop.getTarget()) and
  // Establish the relationship between the name node and the iteration variable
  varDefNode.defines(iterationVar) and
  // Identify conflicting import aliases within the same scope hierarchy
  exists(Import moduleImport, Name importedAlias |
    // Ensure the imported alias shares the same identifier as the iteration variable
    importedAlias.getId() = iterationVar.getId() and
    // Verify the alias is defined through an import statement's 'as' clause
    importedAlias = moduleImport.getAName().getAsname() and
    // Confirm the import is accessible within the iteration variable's scope chain
    moduleImport.getScope() = iterationVar.getScope().getScope*()
  )
// Report the variable definition location with a descriptive shadowing warning message
select varDefNode, "Loop variable '" + iterationVar.getId() + "' shadows an imported module alias."