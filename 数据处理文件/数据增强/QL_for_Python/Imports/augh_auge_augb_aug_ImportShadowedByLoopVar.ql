/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable name conflicts with an imported module alias,
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

// Identify loop variables that shadow imported module aliases
from Variable shadowingVar, Name varDefinitionNode
where 
  // Check for an imported module alias being shadowed by a loop variable
  exists(Import importedModule, Name moduleAlias |
    // Condition 1: The loop variable name matches the imported module alias
    moduleAlias.getId() = shadowingVar.getId() and
    
    // Condition 2: The alias is explicitly defined via an 'as' clause in import
    moduleAlias = importedModule.getAName().getAsname() and
    
    // Condition 3: The import's scope contains the loop variable's scope
    importedModule.getScope() = shadowingVar.getScope().getScope*() and
    
    // Condition 4: The name node defines our shadowing loop variable
    varDefinitionNode.defines(shadowingVar) and
    
    // Condition 5: The definition is the target of a for loop (confirming loop variable)
    exists(For loopStmt | varDefinitionNode = loopStmt.getTarget())
  )
// Select the variable definition node and generate a warning about the shadowing issue
select varDefinitionNode, "Loop variable '" + shadowingVar.getId() + "' shadows an import."