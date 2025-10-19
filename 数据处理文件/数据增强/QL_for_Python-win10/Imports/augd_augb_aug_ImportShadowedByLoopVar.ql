/**
 * @name Import shadowed by loop variable
 * @description Identifies instances where a loop variable shares the same name as an imported module,
 *              which can lead to code confusion and potential runtime errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import the Python analysis library to examine code structures and relationships
import python

// Identify variables that shadow imported module names within loop constructs
from Variable shadowingVariable, Name variableDefinition
where 
  // Verify there's an import statement being shadowed by our variable
  exists(Import importedModule, Name importedAlias |
    // The imported alias name must match the loop variable identifier
    importedAlias.getId() = shadowingVariable.getId() and
    
    // Ensure the alias is defined via an 'as' clause in an import statement
    importedAlias = importedModule.getAName().getAsname() and
    
    // Confirm the import's scope encompasses the variable's scope (hierarchical containment)
    importedModule.getScope() = shadowingVariable.getScope().getScope*() and
    
    // Validate that the name definition corresponds to our shadowing variable
    variableDefinition.defines(shadowingVariable) and
    
    // Ensure the definition is used as a target in a for loop (confirming loop variable status)
    exists(For forLoopStatement | variableDefinition = forLoopStatement.getTarget())
  )
// Select the variable definition node and generate an appropriate warning message
select variableDefinition, "Loop variable '" + shadowingVariable.getId() + "' shadows an import."