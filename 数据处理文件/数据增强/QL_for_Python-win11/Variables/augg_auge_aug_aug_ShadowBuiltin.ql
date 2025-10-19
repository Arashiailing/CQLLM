/**
 * @name Local variable shadows built-in object
 * @description Detects local variables that override built-in objects, making them 
 *              inaccessible within the current scope and reducing code clarity.
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

// Predicate defining built-in names that can be safely shadowed without causing confusion
predicate isSafeToShadow(string builtinName) {
  builtinName in [
      // Built-ins that are rarely used and pose low confusion risk
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      // Common short names or unavoidable identifiers in code
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate that identifies local variables shadowing built-in objects
predicate shadowsBuiltin(Name varNode, string builtinName, Function enclosingFunction, int sourceLine) {
  exists(LocalVariable localVar |
    varNode.defines(localVar) and // Confirm the name node defines a local variable
    localVar.getId() = builtinName and // Match the variable name
    exists(Builtin::builtin(localVar.getId())) // Verify it shadows a built-in
  ) and
  varNode.getScope() = enclosingFunction and // Get the enclosing function scope
  varNode.getLocation().getStartLine() = sourceLine and // Extract the source line number
  not isSafeToShadow(builtinName) // Exclude cases that are safe to shadow
}

// Predicate to find the first occurrence of a built-in being shadowed in a scope
predicate isFirstShadow(Name varNode, string builtinName) {
  exists(Scope varScope, int firstOccurrenceLine |
    shadowsBuiltin(varNode, builtinName, varScope, firstOccurrenceLine) and
    firstOccurrenceLine = min(int line | shadowsBuiltin(_, builtinName, varScope, line))
  )
}

// Main query: Find the first local variables in each scope that shadow built-in objects
from Name varNode, string builtinName
where isFirstShadow(varNode, builtinName)
select varNode, "Local variable '" + builtinName + "' shadows a built-in object."