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

// Find all variables that shadow imports and their corresponding definitions
from Variable shadowingVar, Name varDefNode
where 
  // Check if there exists an import statement that is being shadowed
  exists(Import importDeclaration, Name importAsName |
    // Condition 1: The import alias name matches the loop variable identifier
    importAsName.getId() = shadowingVar.getId() and
    
    // Condition 2: The alias comes from an import statement's 'as' clause
    importAsName = importDeclaration.getAName().getAsname() and
    
    // Condition 3: The import's scope contains the variable's scope (hierarchical relationship)
    importDeclaration.getScope() = shadowingVar.getScope().getScope*() and
    
    // Condition 4: The name definition actually defines our shadowing variable
    varDefNode.defines(shadowingVar) and
    
    // Condition 5: The definition is the target of a for loop (confirming it's a loop variable)
    exists(For forStmt | varDefNode = forStmt.getTarget())
  )
// Select the variable definition node and generate a warning message about the shadowing issue
select varDefNode, "Loop variable '" + shadowingVar.getId() + "' shadows an import."