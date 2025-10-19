/**
 * @name Local variable shadows built-in object
 * @description Detects local variables that override built-in objects, which 
 *              makes built-ins inaccessible in the current scope and reduces code clarity.
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

// Defines built-in names that can be safely shadowed without causing significant confusion
predicate isSafeToShadow(string builtinName) {
  builtinName in [
      // Rarely used built-ins with low confusion risk
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      // Common short names or unavoidable identifiers
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Identifies local variables that shadow built-in objects
predicate shadowsBuiltin(Name shadowingName, string builtinName, Function enclosingFunction, int sourceLine) {
  exists(LocalVariable shadowedVar |
    shadowingName.defines(shadowedVar) and // Verify the name defines a local variable
    shadowedVar.getId() = builtinName and // Match variable name to built-in
    exists(Builtin::builtin(shadowedVar.getId())) // Confirm it shadows a built-in
  ) and
  shadowingName.getScope() = enclosingFunction and // Get containing function scope
  shadowingName.getLocation().getStartLine() = sourceLine and // Extract source line number
  not isSafeToShadow(builtinName) // Exclude safe-to-shadow cases
}

// Finds the first occurrence of a built-in being shadowed in any scope
predicate isFirstShadow(Name shadowingName, string builtinName) {
  exists(Scope enclosingScope, int minLine |
    shadowsBuiltin(shadowingName, builtinName, enclosingScope, minLine) and
    minLine = min(int line | shadowsBuiltin(_, builtinName, enclosingScope, line))
  )
}

// Main query: Detect first local variables in each scope that shadow built-ins
from Name shadowingName, string builtinName
where isFirstShadow(shadowingName, builtinName)
select shadowingName, "Local variable '" + builtinName + "' shadows a built-in object."