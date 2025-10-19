/**
 * @name Import shadowed by loop variable
 * @description Identifies loop variables that shadow imported module names
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import Python analysis library
import python

/**
 * Determines if a variable shadows an imported module alias
 * @param shadowingVar - The variable to check for shadowing
 */
predicate shadowsImportedModule(Variable shadowingVar) {
  exists(Import importStmt, Name aliasName |
    // Identify imported module alias
    aliasName = importStmt.getAName().getAsname() and
    // Verify variable name matches imported alias
    aliasName.getId() = shadowingVar.getId() and
    // Ensure import scope encompasses variable scope
    importStmt.getScope() = shadowingVar.getScope().getScope*()
  )
}

// Find loop variables that shadow imports and their definition locations
from Variable shadowingVar, Name defNode
where 
  // Variable shadows an imported module
  shadowsImportedModule(shadowingVar) and
  // Name node defines the shadowing variable
  defNode.defines(shadowingVar) and
  // Definition occurs as for-loop target
  exists(For loopStmt | defNode = loopStmt.getTarget())
// Select definition point with descriptive message
select defNode, "Loop variable '" + shadowingVar.getId() + "' shadows an imported module name."