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

// Find all variables that conflict with imports and their corresponding definitions
from Variable conflictingVar, Name varDefinition
where 
  // Verify existence of an import statement whose alias conflicts with the loop variable
  exists(Import importStmt, Name importAlias |
    // The import alias identifier matches the loop variable identifier
    importAlias.getId() = conflictingVar.getId() and
    
    // The alias originates from an 'as' clause in the import statement
    importAlias = importStmt.getAName().getAsname() and
    
    // The import's scope hierarchically contains the variable's scope
    importStmt.getScope() = conflictingVar.getScope().getScope*() and
    
    // The name definition actually defines our conflicting variable
    varDefinition.defines(conflictingVar) and
    
    // The definition is the target of a for loop, confirming it's a loop variable
    exists(For loopStatement | varDefinition = loopStatement.getTarget())
  )
// Select the variable definition node and generate a warning message about the conflict
select varDefinition, "Loop variable '" + conflictingVar.getId() + "' shadows an import."