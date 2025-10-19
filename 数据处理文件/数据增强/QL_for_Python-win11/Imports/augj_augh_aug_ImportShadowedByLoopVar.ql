/**
 * @name Import shadowed by loop variable
 * @description Identifies instances where a loop variable's name conflicts with an imported module alias,
 *              which can lead to code confusion and potential runtime errors.
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

// Find loop variables that have the same name as imported modules
from Variable iterVar, Name varNode
where 
  // Check if the variable is defined as a loop target in a for-statement
  exists(For iterationStmt | varNode = iterationStmt.getTarget()) and
  // Establish that the name definition corresponds to our iteration variable
  varNode.defines(iterVar) and
  // Verify there's a conflicting import in an enclosing scope
  exists(Import moduleImport, Name importAlias |
    // Ensure the iteration variable and import alias have matching identifiers
    importAlias.getId() = iterVar.getId() and
    // Confirm the alias comes from an import statement
    importAlias = moduleImport.getAName().getAsname() and
    // Check that the import's scope contains the variable's scope
    moduleImport.getScope() = iterVar.getScope().getScope*()
  )
// Output the problematic definition with an informative message
select varNode, "Loop variable '" + iterVar.getId() + "' shadows an import."