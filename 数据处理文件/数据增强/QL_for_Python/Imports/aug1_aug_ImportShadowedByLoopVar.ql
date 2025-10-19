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

// Identify variables that shadow imported module aliases within loop constructs
from Variable iterationVar, Name varDefNode
where 
  // Verify the variable is defined as a loop iteration target
  exists(For forStmt | varDefNode = forStmt.getTarget()) and
  // Ensure the variable definition corresponds to our iteration variable
  varDefNode.defines(iterationVar) and
  // Check for conflicting import alias within the same scope hierarchy
  exists(Import importDecl, Name importedAlias |
    // The imported alias must match the iteration variable's identifier
    importedAlias.getId() = iterationVar.getId() and
    // Alias must originate from an import statement's 'as' clause
    importedAlias = importDecl.getAName().getAsname() and
    // Import must be accessible in the iteration variable's scope
    importDecl.getScope() = iterationVar.getScope().getScope*()
  )
// Report the variable definition with a descriptive shadowing warning
select varDefNode, "Loop variable '" + iterationVar.getId() + "' shadows an imported module alias."