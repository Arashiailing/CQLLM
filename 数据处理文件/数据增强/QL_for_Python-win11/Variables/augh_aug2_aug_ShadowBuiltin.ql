/**
 * @name Builtin shadowed by local variable
 * @description Detects local variables that shadow built-in objects, making the built-in
 *              object inaccessible within the current scope and reducing code readability.
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

// Predicate to check if a variable name is in the allowlist of names that can safely shadow builtins
// These are considered acceptable because they're either rarely used or difficult to avoid in practice
predicate isSafeToShadow(string builtinName) {
  builtinName in [
      /* Rarely used builtins, unlikely to cause confusion */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Short names and/or difficult to avoid */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to identify local variables that shadow builtins and capture their contextual information
predicate findShadowingVariable(Name identifier, string builtinName, Function enclosingScope, int lineNumber) {
  exists(LocalVariable localVar |
    identifier.defines(localVar) and // Verify the node defines a local variable
    localVar.getId() = builtinName and // Match the variable name
    exists(Builtin::builtin(localVar.getId())) // Confirm it shadows a builtin
  ) and
  identifier.getScope() = enclosingScope and // Capture the enclosing scope
  identifier.getLocation().getStartLine() = lineNumber and // Record source line
  not isSafeToShadow(builtinName) // Exclude permitted shadowing cases
}

// Predicate to locate the first occurrence of builtin shadowing in a specific scope
predicate isFirstShadowInScope(Name identifier, string builtinName) {
  exists(int firstLine, Scope functionScope |
    findShadowingVariable(identifier, builtinName, functionScope, firstLine) and // Identify shadowing
    firstLine = min(int line | findShadowingVariable(_, builtinName, functionScope, line)) // Find earliest instance
  )
}

// Main query: Identify local variables that shadow built-in objects at their first occurrence
from Name identifier, string builtinName
where isFirstShadowInScope(identifier, builtinName) // Filter for first shadowing instances
select identifier, "Local variable '" + builtinName + "' shadows a builtin variable." // Report findings