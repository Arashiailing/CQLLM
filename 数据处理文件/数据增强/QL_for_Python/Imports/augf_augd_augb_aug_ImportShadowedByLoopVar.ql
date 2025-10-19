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

// Find loop variables that shadow imported module names
from Variable loopVar, Name varDefNode
where 
  // Check for an import statement being shadowed by our loop variable
  exists(Import moduleImport, Name importAlias |
    // Condition 1: The import alias name matches the loop variable identifier
    importAlias.getId() = loopVar.getId() and
    
    // Condition 2: The alias is defined via an 'as' clause in an import statement
    importAlias = moduleImport.getAName().getAsname() and
    
    // Condition 3: The import's scope encompasses the variable's scope
    moduleImport.getScope() = loopVar.getScope().getScope*() and
    
    // Condition 4: The name definition corresponds to our loop variable
    varDefNode.defines(loopVar) and
    
    // Condition 5: The definition is used as a target in a for loop
    exists(For forStmt | varDefNode = forStmt.getTarget())
  )
// Select the variable definition node and generate an appropriate warning message
select varDefNode, "Loop variable '" + loopVar.getId() + "' shadows an import."