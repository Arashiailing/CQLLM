/**
 * @name Import shadowed by loop variable
 * @description Detects loop variables that share names with imported module aliases,
 *              potentially causing confusion by obscuring the imported identifier.
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

// Identify loop variables that conflict with imported module aliases
from Variable loopVariable, Name variableNode
where 
  // Verify the variable is defined as a loop iteration target
  exists(For forLoop | variableNode = forLoop.getTarget()) and
  // Associate the name node with the loop variable definition
  variableNode.defines(loopVariable) and
  // Find conflicting import alias within accessible scope
  exists(Import importStmt, Name importAlias |
    // Match identifiers between loop variable and import alias
    importAlias.getId() = loopVariable.getId() and
    // Ensure alias originates from an 'as' clause in import
    importAlias = importStmt.getAName().getAsname() and
    // Confirm import is reachable in the loop variable's scope hierarchy
    importStmt.getScope() = loopVariable.getScope().getScope*()
  )
// Report the variable definition with shadowing warning
select variableNode, "Loop variable '" + loopVariable.getId() + "' shadows an imported module alias."