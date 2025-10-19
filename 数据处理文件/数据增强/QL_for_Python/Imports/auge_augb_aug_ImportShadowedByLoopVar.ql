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

// Identify loop variables that conflict with imported module names
from Variable conflictingVar, Name definitionNode
where 
  // Check for existence of an import statement being shadowed
  exists(Import importedModule, Name moduleAlias |
    // Condition 1: The imported alias name matches the loop variable identifier
    moduleAlias.getId() = conflictingVar.getId() and
    
    // Condition 2: The alias originates from an import statement's 'as' clause
    moduleAlias = importedModule.getAName().getAsname() and
    
    // Condition 3: The import's scope encompasses the variable's scope (hierarchical relationship)
    importedModule.getScope() = conflictingVar.getScope().getScope*() and
    
    // Condition 4: The name definition actually defines our conflicting variable
    definitionNode.defines(conflictingVar) and
    
    // Condition 5: The definition serves as the target of a for loop (confirming loop variable status)
    exists(For loopStatement | definitionNode = loopStatement.getTarget())
  )
// Select the variable definition node and generate a warning message about the shadowing issue
select definitionNode, "Loop variable '" + conflictingVar.getId() + "' shadows an import."