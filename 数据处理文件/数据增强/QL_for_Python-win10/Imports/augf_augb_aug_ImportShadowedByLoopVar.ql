/**
 * @name Import shadowed by loop variable
 * @description Identifies instances where a loop variable name conflicts with an imported module name,
 *              which can lead to code confusion or potential bugs.
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
from Variable conflictingVar, Name variableDefinition
where 
  // Check if there exists an import statement that is being shadowed by the variable
  exists(Import importStmt, Name importAlias |
    // Condition 1: The import alias name matches the loop variable identifier
    importAlias.getId() = conflictingVar.getId() and
    
    // Condition 2: The alias originates from an import statement's 'as' clause
    importAlias = importStmt.getAName().getAsname() and
    
    // Condition 3: The import's scope encompasses the variable's scope (hierarchical relationship)
    importStmt.getScope() = conflictingVar.getScope().getScope*() and
    
    // Condition 4: The name definition actually defines our conflicting variable
    variableDefinition.defines(conflictingVar) and
    
    // Condition 5: The definition is the target of a for loop, confirming it's a loop variable
    exists(For forLoop | variableDefinition = forLoop.getTarget())
  )
// Select the variable definition node and generate a warning message about the conflict
select variableDefinition, "Loop variable '" + conflictingVar.getId() + "' shadows an import."