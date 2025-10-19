/**
 * @name Local variable shadows built-in object
 * @description Identifies local variables that shadow built-in objects,
 *              which obscures access to built-ins and reduces code clarity.
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

// Predicate identifying built-in names that can be safely shadowed
predicate isBuiltinShadowingAllowed(string builtinName) {
  builtinName in [
      /* Rarely used built-ins unlikely to cause confusion */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names difficult to avoid due to frequent usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate detecting local variables that shadow built-in objects
predicate isLocalVarShadowingBuiltin(Name nameNode, string builtinName) {
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and
    localVar.getId() = builtinName and
    exists(Builtin::builtin(localVar.getId())) and
    not isBuiltinShadowingAllowed(builtinName)
  )
}

// Main query: Find first occurrences of shadowing variables per scope
from Name problematicNameNode, string builtinName
where 
  isLocalVarShadowingBuiltin(problematicNameNode, builtinName) and
  // Ensure we capture the first occurrence in each scope
  problematicNameNode.getLocation().getStartLine() = min(int line | 
    exists(Name otherNode |
      isLocalVarShadowingBuiltin(otherNode, builtinName) and
      otherNode.getScope() = problematicNameNode.getScope() and
      otherNode.getLocation().getStartLine() = line
    )
  )
select problematicNameNode, "Local variable '" + builtinName + "' shadows a built-in object."