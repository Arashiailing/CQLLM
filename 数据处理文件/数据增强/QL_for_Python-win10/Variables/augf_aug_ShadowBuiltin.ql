/**
 * @name Builtin shadowed by local variable
 * @description Identifies local variables that shadow built-in objects, making the built-in
 *              inaccessible in the current scope and reducing code clarity.
 * @kind problem
 * @tags maintainability
 *       readability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/local-shadows-builtin
 */

import python
import semmle.python.types.Builtins

// Determines if a variable name is permitted to shadow builtins (low-risk names)
predicate isPermittedShadow(string name) {
  name in [
      /* Rarely used builtins with low confusion risk */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Checks if a name node defines a local variable that shadows a builtin
predicate isShadowingBuiltin(Name nameNode, string varName, Function enclosingScope, int lineNum) {
  exists(LocalVariable localDef |
    nameNode.defines(localDef) and // Verify the name defines a local variable
    localDef.getId() = varName and // Match the variable name
    exists(Builtin::builtin(localDef.getId())) // Confirm it's a builtin name
  ) and
  nameNode.getScope() = enclosingScope and // Capture the enclosing scope
  nameNode.getLocation().getStartLine() = lineNum and // Get source line number
  not isPermittedShadow(varName) // Exclude permitted shadowing names
}

// Identifies the first occurrence of shadowing for a variable in its scope
predicate isFirstShadowingInstance(Name nameNode, string varName) {
  exists(int firstOccurrenceLine, Scope scope |
    isShadowingBuiltin(nameNode, varName, scope, firstOccurrenceLine) and // Check shadowing
    firstOccurrenceLine = min(int line | isShadowingBuiltin(_, varName, scope, line)) // Get earliest line
  )
}

// Main query: Report local variables that shadow built-in objects
from Name nameNode, string varName
where isFirstShadowingInstance(nameNode, varName) // Focus on first shadowing occurrences
select nameNode, "Local variable '" + varName + "' shadows a builtin variable." // Report finding