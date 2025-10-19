/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable name conflicts with an imported module alias,
 *              potentially causing confusion or bugs by obscuring the imported identifier.
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

// Identify loop variables that shadow imported module aliases
from Variable loopVar, Name varNode
where 
  // Verify the variable is defined as a loop iteration target
  exists(For loopStmt | varNode = loopStmt.getTarget()) and
  // Ensure the variable definition corresponds to our loop variable
  varNode.defines(loopVar) and
  // Check for conflicting import alias within the same scope hierarchy
  exists(Import importDecl, Name aliasNode |
    // The imported alias must match the loop variable's identifier
    aliasNode.getId() = loopVar.getId() and
    // Alias must originate from an import statement's 'as' clause
    aliasNode = importDecl.getAName().getAsname() and
    // Import must be accessible in the loop variable's scope
    importDecl.getScope() = loopVar.getScope().getScope*()
  )
// Report the variable definition with a descriptive shadowing warning
select varNode, "Loop variable '" + loopVar.getId() + "' shadows an imported module alias."