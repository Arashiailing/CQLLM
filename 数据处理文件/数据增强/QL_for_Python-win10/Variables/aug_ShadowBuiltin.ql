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

// Predicate to determine if a variable name is in the allowlist (names that can safely shadow builtins)
predicate isAllowedName(string varName) {
  varName in [
      /* Rarely used builtins, unlikely to cause confusion */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Short names and/or difficult to avoid */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to check if a name node represents a local variable that shadows a builtin
predicate shadowsBuiltin(Name nameNode, string varName, Function scope, int lineNum) {
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and // Verify the name node defines a local variable
    localVar.getId() = varName and // Check the local variable's name matches
    exists(Builtin::builtin(localVar.getId())) // Confirm the name is a builtin
  ) and
  nameNode.getScope() = scope and // Get the enclosing scope
  nameNode.getLocation().getStartLine() = lineNum and // Get the line number
  not isAllowedName(varName) // Ensure the name is not in the allowlist
}

// Predicate to identify the first occurrence of a variable shadowing a builtin in a given scope
predicate isFirstShadowing(Name nameNode, string varName) {
  exists(int firstLine, Scope currentScope |
    shadowsBuiltin(nameNode, varName, currentScope, firstLine) and // Check if it's a shadowing builtin
    firstLine = min(int line | shadowsBuiltin(_, varName, currentScope, line)) // Find the first occurrence
  )
}

// Main query: Find all local variables that shadow built-in objects
from Name nameNode, string varName
where isFirstShadowing(nameNode, varName) // Filter for first shadowing occurrences
select nameNode, "Local variable '" + varName + "' shadows a builtin variable." // Report the shadowing variable