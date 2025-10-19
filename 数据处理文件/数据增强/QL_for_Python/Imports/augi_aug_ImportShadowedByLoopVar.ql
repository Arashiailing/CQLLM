/**
 * @name Import shadowed by loop variable
 * @description Identifies instances where a loop variable name conflicts with an imported module alias,
 *              which can lead to code confusion or unexpected behavior.
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

// Find all loop variables that shadow imported module names
from Variable iterationVar, Name varName
where 
  // There exists an import statement with an alias that matches our loop variable
  exists(Import impStmt, Name importedAlias |
    // The imported alias identifier must match the loop variable identifier
    importedAlias.getId() = iterationVar.getId() and
    // The alias must be defined as an 'asname' in the import statement
    importedAlias = impStmt.getAName().getAsname() and
    // The import's scope must encompass the loop variable's scope
    impStmt.getScope() = iterationVar.getScope().getScope*() and
    // The name definition must correspond to our loop variable
    varName.defines(iterationVar) and
    // Verify the definition is indeed the target of a for loop
    exists(For loopStmt | varName = loopStmt.getTarget())
  )
// Output the problematic definition with a descriptive warning message
select varName, "Loop variable '" + iterationVar.getId() + "' shadows an import."