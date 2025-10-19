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

// Determines if a built-in name is in the safe list, allowing shadowing without issues
predicate isSafeShadowingName(string builtinName) {
  builtinName in [
      /* Built-in names that are rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid using due to their brevity or common usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Checks if a name node represents a local variable shadowing a built-in object
predicate localVarShadowsBuiltin(Name nameNode, string builtinName, Function funcScope, int lineNum) {
  not isSafeShadowingName(builtinName) and
  exists(Builtin::builtin(builtinName)) and
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and
    localVar.getId() = builtinName
  ) and
  nameNode.getScope() = funcScope and
  nameNode.getLocation().getStartLine() = lineNum
}

// Identifies the first occurrence of a variable shadowing a built-in within a given scope
predicate isFirstShadowingOccurrence(Name nameNode, string builtinName) {
  exists(int firstLine, Function funcScope |
    localVarShadowsBuiltin(nameNode, builtinName, funcScope, firstLine) and
    firstLine = min(int line | localVarShadowsBuiltin(_, builtinName, funcScope, line))
  )
}

// Main query: Detects all local variables that shadow built-in objects
from Name nameNode, string builtinName
where isFirstShadowingOccurrence(nameNode, builtinName)
select nameNode, "Local variable '" + builtinName + "' shadows a built-in object."