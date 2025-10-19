/**
 * @name Local variable shadows built-in object
 * @description Identifies local variables that share names with built-in objects,
 *              which blocks access to the built-in object within that scope and
 *              reduces code readability and maintainability.
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

// Predicate to determine if a builtin name is in the permissible list (names that can be safely shadowed)
predicate isPermissibleShadowing(string builtinObjName) {
  builtinObjName in [
      /* Builtin names that are rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid due to their brevity or frequent usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to identify name nodes defining local variables that shadow builtin objects
predicate definesShadowingVar(Name varNameNode, string builtinObjName) {
  exists(LocalVariable localVarDef |
    varNameNode.defines(localVarDef) and
    localVarDef.getId() = builtinObjName and
    exists(Builtin::builtin(localVarDef.getId())) and
    not isPermissibleShadowing(builtinObjName)
  )
}

// Main query: Detect initial occurrences of local variables shadowing builtin objects
from Name varNameNode, string builtinObjName, int firstOccurrenceLine
where 
  definesShadowingVar(varNameNode, builtinObjName) and
  // Calculate the first occurrence line number within the same scope
  firstOccurrenceLine = min(int line | 
    exists(Name otherNode |
      definesShadowingVar(otherNode, builtinObjName) and
      otherNode.getScope() = varNameNode.getScope() and
      otherNode.getLocation().getStartLine() = line
    )
  ) and
  // Ensure current node is the first occurrence
  varNameNode.getLocation().getStartLine() = firstOccurrenceLine
select varNameNode, "Local variable '" + builtinObjName + "' shadows a built-in object."