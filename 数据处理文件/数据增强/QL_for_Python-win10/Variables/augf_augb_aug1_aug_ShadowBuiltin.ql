/**
 * @name Local Variable Shadowing Built-in Object
 * @description Identifies local variables that share names with built-in objects.
 *              Such shadowing obscures the built-in object within the current scope,
 *              potentially degrading code clarity and maintainability.
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

// Checks if a built-in name is in the safe list, allowing shadowing without significant risk
predicate isSafeShadowingName(string builtinObjName) {
  builtinObjName in [
      /* Built-ins rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names difficult to avoid due to brevity or frequent usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Confirms a name node represents a local variable shadowing a built-in object
predicate localVarShadowsBuiltin(Name varNameNode, string builtinObjName, Function funcScope, int lineNumber) {
  not isSafeShadowingName(builtinObjName) and
  exists(LocalVariable localVarDecl |
    varNameNode.defines(localVarDecl) and
    localVarDecl.getId() = builtinObjName and
    exists(Builtin::builtin(localVarDecl.getId()))
  ) and
  varNameNode.getScope() = funcScope and
  varNameNode.getLocation().getStartLine() = lineNumber
}

// Locates the first occurrence of a variable shadowing a built-in within its scope
predicate isFirstShadowingOccurrence(Name varNameNode, string builtinObjName) {
  exists(int firstLineNumber, Scope funcScope |
    localVarShadowsBuiltin(varNameNode, builtinObjName, funcScope, firstLineNumber) and
    firstLineNumber = min(int line | localVarShadowsBuiltin(_, builtinObjName, funcScope, line))
  )
}

// Main query: Detects all local variables shadowing built-in objects
from Name varNameNode, string builtinObjName
where isFirstShadowingOccurrence(varNameNode, builtinObjName)
select varNameNode, "Local variable '" + builtinObjName + "' shadows a built-in object."