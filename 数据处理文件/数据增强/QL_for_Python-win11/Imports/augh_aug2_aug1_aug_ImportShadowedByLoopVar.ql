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

import python

from Variable loopVariable, Name variableNameNode
where 
  // Verify the variable is defined as a loop iteration target
  exists(For loopStatement | variableNameNode = loopStatement.getTarget()) and
  variableNameNode.defines(loopVariable) and
  // Identify conflicting import alias in the same scope hierarchy
  exists(Import importStmt, Name aliasNode |
    // Alias must originate from an import statement's 'as' clause
    aliasNode = importStmt.getAName().getAsname() and
    // Alias identifier must match the loop variable's name
    aliasNode.getId() = loopVariable.getId() and
    // Import must be accessible in the loop variable's scope
    importStmt.getScope() = loopVariable.getScope().getScope*()
  )
select variableNameNode, "Loop variable '" + loopVariable.getId() + "' shadows an imported module alias."