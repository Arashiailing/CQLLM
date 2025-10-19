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

// Import Python analysis library for code examination
import python

// Define a predicate to determine if a variable shadows an imported name
predicate shadowsImport(Variable loopVar) {
  // There exists an import statement and a name that is being shadowed
  exists(Import importStmt, Name shadowedName |
    // The shadowed name is the alias of an imported module
    shadowedName = importStmt.getAName().getAsname() and
    // The shadowed name has the same identifier as the loop variable
    shadowedName.getId() = loopVar.getId() and
    // The import's scope encompasses the loop variable's scope
    importStmt.getScope() = loopVar.getScope().getScope*()
  )
}

// Select all relevant variables and name definitions that meet our criteria
from Variable loopVar, Name nameDefn
// Condition 1: The loop variable shadows an import
where shadowsImport(loopVar) and
      // Condition 2: The name definition defines the loop variable
      nameDefn.defines(loopVar) and
      // Condition 3: There exists a for loop where the target is the name definition
      exists(For forLoop | nameDefn = forLoop.getTarget())
// Select the name definition and generate a warning message about the shadowed import
select nameDefn, "Loop variable '" + loopVar.getId() + "' shadows an import."