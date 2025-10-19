/**
 * @name Import shadowed by loop variable
 * @description Identifies loop variables that reuse names from imported modules,
 *              potentially causing confusion and maintenance issues.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

import python

from Variable loopVariable, Name nameDefinition
where
  // Verify the loop variable reuses an imported module's alias
  exists(Import importDeclaration, Name aliasedImportName |
    aliasedImportName = importDeclaration.getAName().getAsname() and
    aliasedImportName.getId() = loopVariable.getId() and
    importDeclaration.getScope() = loopVariable.getScope().getScope*()
  ) and
  // Ensure the name definition corresponds to the loop variable
  nameDefinition.defines(loopVariable) and
  // Confirm the name definition is used in a for-loop target
  exists(For forStmt | nameDefinition = forStmt.getTarget())
select nameDefinition, "Loop variable '" + loopVariable.getId() + "' shadows an import."