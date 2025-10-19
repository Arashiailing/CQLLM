/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable shadows an imported module or name.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// Import the Python analysis library to enable code examination capabilities
import python

// Define a predicate that identifies when a variable shadows an imported name
predicate shadowsImport(Variable iterationVar) {
  exists(Import importedModule, Name obscuredName |
    // The obscured name corresponds to an alias of an imported module
    obscuredName = importedModule.getAName().getAsname() and
    // The obscured name shares the same identifier as the iteration variable
    obscuredName.getId() = iterationVar.getId() and
    // The scope of the import includes the scope of the iteration variable
    importedModule.getScope() = iterationVar.getScope().getScope*()
  )
}

// Check if a name definition corresponds to a for loop target
predicate isForLoopTarget(Name nameDefn) {
  exists(For loopStatement | nameDefn = loopStatement.getTarget())
}

// Query to find all relevant variables and name definitions matching our criteria
from Variable iterationVar, Name varDefinition
// Combine conditions: variable shadows import, is defined by the name, and is a for loop target
where shadowsImport(iterationVar) and
      varDefinition.defines(iterationVar) and
      isForLoopTarget(varDefinition)
// Output the name definition with a warning about the shadowed import
select varDefinition, "Loop variable '" + iterationVar.getId() + "' shadows an import."