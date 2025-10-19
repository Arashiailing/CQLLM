/**
 * @name Import shadowed by loop variable
 * @description Identifies loop variables that share names with imported module aliases,
 *              which may lead to code confusion or unexpected behavior.
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

// Identify loop variables that conflict with imported aliases
from Variable iterationVar, Name variableNode
where 
  // Verify the variable is defined in a for loop context
  exists(For loopStmt | variableNode = loopStmt.getTarget()) and
  // Confirm the variable node defines our iteration variable
  variableNode.defines(iterationVar) and
  // Find matching import alias with same identifier
  exists(Import importDeclaration, Name importedAlias |
    // Identifier must match between loop variable and import alias
    importedAlias.getId() = iterationVar.getId() and
    // Alias must originate from import statement's asname clause
    importedAlias = importDeclaration.getAName().getAsname() and
    // Import scope must contain the loop variable's scope
    importDeclaration.getScope() = iterationVar.getScope().getScope*()
  )
// Report the conflicting variable definition with descriptive message
select variableNode, "Loop variable '" + iterationVar.getId() + "' shadows an import."