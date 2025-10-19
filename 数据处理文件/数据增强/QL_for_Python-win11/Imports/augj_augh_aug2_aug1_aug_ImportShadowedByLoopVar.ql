/**
 * @name Import shadowed by loop variable
 * @description Identifies when a loop variable uses the same name as an imported module alias,
 *              which can lead to confusion by hiding the imported identifier.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

import python

from Variable iterationVar, Name varNameNode
where 
  // Ensure the variable is defined as a loop iteration target
  exists(For forLoopStmt | varNameNode = forLoopStmt.getTarget()) and
  varNameNode.defines(iterationVar) and
  // Check for conflicting import alias within the same scope hierarchy
  exists(Import moduleImport, Name importAlias |
    // The alias must come from an import statement's 'as' clause
    importAlias = moduleImport.getAName().getAsname() and
    // The alias identifier must match the loop variable's identifier
    importAlias.getId() = iterationVar.getId() and
    // The import must be accessible within the loop variable's scope
    moduleImport.getScope() = iterationVar.getScope().getScope*()
  )
select varNameNode, "Loop variable '" + iterationVar.getId() + "' shadows an imported module alias."