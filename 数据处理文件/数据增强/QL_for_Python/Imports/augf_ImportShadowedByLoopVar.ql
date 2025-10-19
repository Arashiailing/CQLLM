/**
 * @name Import shadowed by loop variable
 * @description Detects when a loop variable shadows an imported module name,
 *              which can lead to confusion and potential bugs.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

import python

/**
 * Determines if a variable shadows an imported module name.
 * This predicate checks if there exists an import statement whose
 * aliased name matches the variable identifier and is in an enclosing scope.
 */
predicate isShadowingImport(Variable loopVar) {
  exists(Import importStmt, Name shadowedName |
    // The shadowed name is the alias of an imported module
    shadowedName = importStmt.getAName().getAsname() and
    // The variable identifier matches the shadowed name
    shadowedName.getId() = loopVar.getId() and
    // The import is in a scope that encloses the variable's scope
    importStmt.getScope() = loopVar.getScope().getScope*()
  )
}

from Variable loopVar, Name nameDef
where
  // The loop variable shadows an import
  isShadowingImport(loopVar) and
  // The name definition defines the loop variable
  nameDef.defines(loopVar) and
  // The name definition is the target of a for loop
  exists(For forLoop | nameDef = forLoop.getTarget())
select nameDef, "Loop variable '" + loopVar.getId() + "' shadows an import."