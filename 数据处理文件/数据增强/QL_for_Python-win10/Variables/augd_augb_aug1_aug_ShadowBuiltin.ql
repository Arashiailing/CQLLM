/**
 * @name Local Variable Shadowing Built-in Object
 * @description Detects local variables that share names with built-in objects.
 *              This shadowing makes the built-in object inaccessible within the current scope,
 *              potentially reducing code clarity and maintainability.
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

// Determines if a built-in object name is in the safe list, allowing it to be shadowed without issues
predicate isSafeShadowingName(string builtinObjectName) {
  builtinObjectName in [
      /* Built-in names that are rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid using due to their brevity or common usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Checks if a name node represents a local variable that shadows a built-in object
predicate localVarShadowsBuiltin(Name variableNameNode, string builtinObjectName, Function functionScope, int lineNumber) {
  not isSafeShadowingName(builtinObjectName) and
  exists(LocalVariable localVariable |
    variableNameNode.defines(localVariable) and
    localVariable.getId() = builtinObjectName and
    exists(Builtin::builtin(localVariable.getId()))
  ) and
  variableNameNode.getScope() = functionScope and
  variableNameNode.getLocation().getStartLine() = lineNumber
}

// Identifies the first occurrence of a variable shadowing a built-in within a given scope
predicate isFirstShadowingOccurrence(Name variableNameNode, string builtinObjectName) {
  exists(int firstOccurrenceLine, Function functionScope |
    localVarShadowsBuiltin(variableNameNode, builtinObjectName, functionScope, firstOccurrenceLine) and
    firstOccurrenceLine = min(int line | localVarShadowsBuiltin(_, builtinObjectName, functionScope, line))
  )
}

// Main query: Detects all local variables that shadow built-in objects
from Name variableNameNode, string builtinObjectName
where isFirstShadowingOccurrence(variableNameNode, builtinObjectName)
select variableNameNode, "Local variable '" + builtinObjectName + "' shadows a built-in object."