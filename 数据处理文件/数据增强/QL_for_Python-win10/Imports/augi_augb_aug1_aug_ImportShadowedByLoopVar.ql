/**
 * @name Import shadowed by loop variable
 * @description Identifies situations where a loop variable's name conflicts with 
 *              an imported module alias, which can lead to code confusion and potential bugs
 *              by making the imported identifier inaccessible within the loop.
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

// Find loop iteration variables that conflict with imported module aliases
from Variable iterationVar, Name varIdentifier
where 
  // Confirm the variable is used as a loop iteration target
  exists(For forLoop | varIdentifier = forLoop.getTarget()) and
  // Establish the relationship between the identifier and the variable
  varIdentifier.defines(iterationVar) and
  // Look for conflicting import aliases in the same scope hierarchy
  exists(Import moduleImport, Name importAlias |
    // The import alias must have the same name as the loop variable
    importAlias.getId() = iterationVar.getId() and
    // The alias must come from an import statement's 'as' clause
    importAlias = moduleImport.getAName().getAsname() and
    // The import must be accessible in the loop variable's scope
    moduleImport.getScope() = iterationVar.getScope().getScope*()
  )
// Report the problematic variable definition with a descriptive message
select varIdentifier, "Loop variable '" + iterationVar.getId() + "' shadows an imported module alias."