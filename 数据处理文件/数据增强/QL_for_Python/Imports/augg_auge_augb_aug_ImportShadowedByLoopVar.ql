/**
 * @name Import shadowed by loop variable
 * @description Identifies instances where a loop variable name conflicts with an imported module alias,
 *              which may lead to code confusion or unintended behavior.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import the Python analysis library to enable examination of Python code structures
import python

// Find loop variables whose names shadow imported module aliases
from Variable shadowingVar, Name varDefinition
where 
  // Verify that there is an import statement with an alias that is being shadowed
  exists(Import moduleImport, Name importAlias |
    // Ensure the imported alias name matches the loop variable identifier
    importAlias.getId() = shadowingVar.getId() and
    
    // Confirm the alias comes from an import statement's 'as' clause
    importAlias = moduleImport.getAName().getAsname() and
    
    // Check that the import's scope contains the variable's scope (parent-child relationship)
    moduleImport.getScope() = shadowingVar.getScope().getScope*() and
    
    // Verify the name node defines our shadowing variable
    varDefinition.defines(shadowingVar) and
    
    // Confirm the variable is used as a loop variable in a for statement
    exists(For forLoop | varDefinition = forLoop.getTarget())
  )
// Select the variable definition node and create a warning message about the shadowing issue
select varDefinition, "Loop variable '" + shadowingVar.getId() + "' shadows an import."