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

// Find all variables and their definitions that meet the shadowing criteria
from Variable loopVar, Name varDefinition
where 
  // Check if the variable shadows an import by matching an import alias
  exists(Import importStmt, Name importAlias |
    // The import alias must match the loop variable identifier
    importAlias.getId() = loopVar.getId() and
    // The alias must come from an import statement's asname
    importAlias = importStmt.getAName().getAsname() and
    // The import's scope must contain the variable's scope
    importStmt.getScope() = loopVar.getScope().getScope*() and
    // The name definition must define our loop variable
    varDefinition.defines(loopVar) and
    // The definition must be the target of a for loop
    exists(For forLoop | varDefinition = forLoop.getTarget())
  )
// Select the definition and generate a warning message about the shadowing
select varDefinition, "Loop variable '" + loopVar.getId() + "' shadows an import."