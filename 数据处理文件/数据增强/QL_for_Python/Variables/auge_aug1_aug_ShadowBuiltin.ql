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

/**
 * Predicate that identifies names which are considered safe to shadow built-in objects.
 * These names are either rarely used built-ins or common names that are difficult to avoid.
 */
predicate isSafeShadowingName(string builtinName) {
  builtinName in [
      /* Built-in names that are rarely used and unlikely to cause confusion when shadowed */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common names that are difficult to avoid using due to their brevity or common usage */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

/**
 * Predicate that determines if a name node represents a local variable that shadows a built-in.
 * @param nameNode - The AST node representing the variable name
 * @param builtinName - The name of the built-in object being shadowed
 * @param enclosingFunc - The function scope containing the variable
 * @param declLine - The line number where the variable is declared
 */
predicate localVarShadowsBuiltin(Name nameNode, string builtinName, Function enclosingFunc, int declLine) {
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and // Confirm the name node defines a local variable
    localVar.getId() = builtinName and // Ensure the local variable's name matches
    exists(Builtin::builtin(localVar.getId())) // Verify the name corresponds to a built-in object
  ) and
  nameNode.getScope() = enclosingFunc and // Get the function scope containing the variable
  nameNode.getLocation().getStartLine() = declLine and // Get the line number where the variable is declared
  not isSafeShadowingName(builtinName) // Exclude names that are safe to shadow
}

/**
 * Predicate that identifies the first occurrence of a variable shadowing a built-in within a specific scope.
 * @param nameNode - The AST node representing the variable name
 * @param builtinName - The name of the built-in object being shadowed
 */
predicate isFirstShadowingOccurrence(Name nameNode, string builtinName) {
  exists(int firstLine, Scope varScope |
    localVarShadowsBuiltin(nameNode, builtinName, varScope, firstLine) and // Check if it's a shadowing occurrence
    firstLine = min(int line | localVarShadowsBuiltin(_, builtinName, varScope, line)) // Find the earliest occurrence
  )
}

// Main query: Detect all local variables that shadow built-in objects
from Name nameNode, string builtinName
where isFirstShadowingOccurrence(nameNode, builtinName) // Filter for the first shadowing occurrence in each scope
select nameNode, "Local variable '" + builtinName + "' shadows a built-in object." // Report the shadowing variable