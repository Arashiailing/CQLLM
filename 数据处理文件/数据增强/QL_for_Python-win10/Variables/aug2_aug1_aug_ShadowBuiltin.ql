/**
 * @name Local variable shadows built-in object
 * @description Detects when a local variable is named the same as a built-in object,
 *              which prevents access to the built-in object in that scope and
 *              negatively impacts code readability and maintenance.
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

// Predicate to check if a builtin name is in the allowed list (names that can be safely shadowed)
predicate isAllowedShadowing(string builtinName) {
  builtinName in [
      /* Builtin names that are infrequently used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are challenging to avoid due to their brevity or common usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to check if a name node defines a local variable that shadows a builtin
predicate isShadowingBuiltin(Name nameNode, string builtinName) {
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and
    localVar.getId() = builtinName and
    exists(Builtin::builtin(localVar.getId())) and
    not isAllowedShadowing(builtinName)
  )
}

// Main query: Identify the first occurrence of local variables that shadow builtin objects
from Name nameNode, string builtinName
where 
  isShadowingBuiltin(nameNode, builtinName) and
  // Ensure this is the first occurrence in the scope
  nameNode.getLocation().getStartLine() = min(int line | 
    exists(Name otherNode |
      isShadowingBuiltin(otherNode, builtinName) and
      otherNode.getScope() = nameNode.getScope() and
      otherNode.getLocation().getStartLine() = line
    )
  )
select nameNode, "Local variable '" + builtinName + "' shadows a built-in object."