/**
 * @name Local variable shadows built-in object
 * @description Identifies local variables that have the same name as built-in objects,
 *              which makes the built-in object inaccessible in the current scope and
 *              reduces code clarity and maintainability.
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

// Predicate that determines if a variable name is in the safe list (names that can shadow builtins without causing issues)
predicate isSafeShadowingName(string shadowedBuiltinName) {
  shadowedBuiltinName in [
      /* Built-in names that are rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid using due to their brevity or common usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate that verifies if a name node represents a local variable that shadows a built-in object
predicate localVarShadowsBuiltin(Name varNameNode, string shadowedBuiltinName, Function enclosingScope, int declarationLine) {
  exists(LocalVariable shadowingLocalVar |
    varNameNode.defines(shadowingLocalVar) and // Confirm the name node defines a local variable
    shadowingLocalVar.getId() = shadowedBuiltinName and // Ensure the local variable's name matches
    exists(Builtin::builtin(shadowingLocalVar.getId())) // Verify the name corresponds to a built-in object
  ) and
  varNameNode.getScope() = enclosingScope and // Get the function scope containing the variable
  varNameNode.getLocation().getStartLine() = declarationLine and // Get the line number where the variable is declared
  not isSafeShadowingName(shadowedBuiltinName) // Exclude names that are safe to shadow
}

// Predicate that identifies the first occurrence of a variable shadowing a built-in within a specific scope
predicate isFirstShadowingOccurrence(Name varNameNode, string shadowedBuiltinName) {
  exists(int firstOccurrenceLine, Scope variableScope |
    localVarShadowsBuiltin(varNameNode, shadowedBuiltinName, variableScope, firstOccurrenceLine) and // Check if it's a shadowing occurrence
    firstOccurrenceLine = min(int line | localVarShadowsBuiltin(_, shadowedBuiltinName, variableScope, line)) // Find the earliest occurrence
  )
}

// Main query: Detect all local variables that shadow built-in objects
from Name varNameNode, string shadowedBuiltinName
where isFirstShadowingOccurrence(varNameNode, shadowedBuiltinName) // Filter for the first shadowing occurrence in each scope
select varNameNode, "Local variable '" + shadowedBuiltinName + "' shadows a built-in object." // Report the shadowing variable