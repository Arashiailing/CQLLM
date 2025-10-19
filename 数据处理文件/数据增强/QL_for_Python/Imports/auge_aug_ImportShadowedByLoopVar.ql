/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable name conflicts with an imported module name,
 *              potentially causing confusion or bugs in the code.
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

// Identify loop variables that shadow imported module names
from Variable shadowingVar, Name varDef
where 
  // Verify the variable is defined in a for-loop context
  exists(For loopStmt | varDef = loopStmt.getTarget()) and
  // Confirm the variable definition corresponds to our target variable
  varDef.defines(shadowingVar) and
  // Check for matching import alias in an accessible scope
  exists(Import importDecl, Name importedAlias |
    // Ensure the alias name matches the loop variable identifier
    importedAlias.getId() = shadowingVar.getId() and
    // Validate the alias originates from an import statement
    importedAlias = importDecl.getAName().getAsname() and
    // Confirm the import is accessible in the variable's scope
    importDecl.getScope() = shadowingVar.getScope().getScope*()
  )
// Report the conflicting definition with descriptive message
select varDef, "Loop variable '" + shadowingVar.getId() + "' shadows an import."