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
 * Predicate that identifies the first occurrence of a variable shadowing a built-in within a specific scope.
 * @param shadowingNameNode - The AST node representing the variable name
 * @param builtinObjName - The name of the built-in object being shadowed
 */
predicate isFirstShadowingOccurrence(Name shadowingNameNode, string builtinObjName) {
  exists(int firstOccurrenceLine, Scope variableScope |
    // Verify this is a shadowing occurrence with the earliest line number in its scope
    localVarShadowsBuiltin(shadowingNameNode, builtinObjName, variableScope, firstOccurrenceLine) and
    firstOccurrenceLine = min(int line | 
      localVarShadowsBuiltin(_, builtinObjName, variableScope, line)
    )
  )
}

/**
 * Predicate that determines if a name node represents a local variable that shadows a built-in.
 * @param varNameNode - The AST node representing the variable name
 * @param builtinObjName - The name of the built-in object being shadowed
 * @param enclosingScopeFunc - The function scope containing the variable
 * @param declarationLine - The line number where the variable is declared
 */
predicate localVarShadowsBuiltin(Name varNameNode, string builtinObjName, Function enclosingScopeFunc, int declarationLine) {
  // Verify the name node defines a local variable matching a built-in object
  exists(LocalVariable localVar |
    varNameNode.defines(localVar) and
    localVar.getId() = builtinObjName and
    exists(Builtin::builtin(localVar.getId()))
  ) and
  // Retrieve scope and location details
  varNameNode.getScope() = enclosingScopeFunc and
  varNameNode.getLocation().getStartLine() = declarationLine and
  // Exclude names that are safe to shadow
  not isSafeShadowingName(builtinObjName)
}

// Main query: Detect all local variables that shadow built-in objects
from Name shadowingNameNode, string builtinObjName
where isFirstShadowingOccurrence(shadowingNameNode, builtinObjName) // Filter for the first shadowing occurrence in each scope
select shadowingNameNode, "Local variable '" + builtinObjName + "' shadows a built-in object." // Report the shadowing variable