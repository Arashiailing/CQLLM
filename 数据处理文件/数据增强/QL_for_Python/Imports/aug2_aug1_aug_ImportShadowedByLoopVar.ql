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

// Find variables that obscure imported module aliases within loop structures
from Variable loopVar, Name varNameNode
where 
  // Confirm that the variable is defined as a loop iteration target
  exists(For loopStmt | varNameNode = loopStmt.getTarget()) and
  // Establish that the variable definition corresponds to our loop variable
  varNameNode.defines(loopVar) and
  // Look for conflicting import alias within the same scope hierarchy
  exists(Import importStatement, Name aliasName |
    // The imported alias must have the same identifier as the loop variable
    aliasName.getId() = loopVar.getId() and
    // Alias must come from an import statement's 'as' clause
    aliasName = importStatement.getAName().getAsname() and
    // Import must be reachable in the loop variable's scope
    importStatement.getScope() = loopVar.getScope().getScope*()
  )
// Output the variable definition with an informative shadowing alert
select varNameNode, "Loop variable '" + loopVar.getId() + "' shadows an imported module alias."