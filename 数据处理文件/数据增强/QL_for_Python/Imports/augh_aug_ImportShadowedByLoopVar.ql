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
from Variable loopVariable, Name variableDefinition
where 
  // Verify the variable is defined in a for-loop context
  exists(For forLoop | variableDefinition = forLoop.getTarget()) and
  // Ensure the name definition corresponds to our loop variable
  variableDefinition.defines(loopVariable) and
  // Check for conflicting import in an enclosing scope
  exists(Import importStatement, Name importedAlias |
    // Match identifiers between loop variable and import alias
    importedAlias.getId() = loopVariable.getId() and
    // Confirm alias originates from an import statement
    importedAlias = importStatement.getAName().getAsname() and
    // Validate import scope contains the variable's scope
    importStatement.getScope() = loopVariable.getScope().getScope*()
  )
// Report the conflicting definition with descriptive message
select variableDefinition, "Loop variable '" + loopVariable.getId() + "' shadows an import."