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
predicate isPermittedShadowing(string builtinName) {
  builtinName in [
      /* Rarely used builtins, unlikely to cause confusion */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Short names and/or difficult to avoid */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to identify local variables that shadow builtins and capture their context
predicate isShadowingBuiltin(Name varNode, string builtinName, Function containerScope, int sourceLine) {
  exists(LocalVariable localVar |
    varNode.defines(localVar) and // Verify the node defines a local variable
    localVar.getId() = builtinName and // Match the variable name
    exists(Builtin::builtin(localVar.getId())) // Confirm it shadows a builtin
  ) and
  varNode.getScope() = containerScope and // Capture the enclosing scope
  varNode.getLocation().getStartLine() = sourceLine and // Record source line
  not isPermittedShadowing(builtinName) // Exclude permitted shadowing cases
}

// Predicate to locate the first occurrence of builtin shadowing in a specific scope
predicate isInitialShadow(Name varNode, string builtinName) {
  exists(int firstOccurrence, Scope relevantScope |
    isShadowingBuiltin(varNode, builtinName, relevantScope, firstOccurrence) and // Identify shadowing
    firstOccurrence = min(int line | isShadowingBuiltin(_, builtinName, relevantScope, line)) // Find earliest instance
  )
}

// Main query: Identify local variables that shadow built-in objects at their first occurrence
from Name varNode, string builtinName
where isInitialShadow(varNode, builtinName) // Filter for first shadowing instances
select varNode, "Local variable '" + builtinName + "' shadows a builtin variable." // Report findings