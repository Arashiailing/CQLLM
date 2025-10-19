/**
 * @name Local variable shadows built-in object
 * @description Identifies local variables that override built-in objects, rendering them 
 *              inaccessible within the current scope and potentially reducing code clarity.
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
predicate isSafeToShadow(string builtinIdentifier) {
  builtinIdentifier in [
      // Built-ins that are rarely used and pose low confusion risk
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      // Common short names or unavoidable identifiers in code
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate that identifies local variables shadowing built-in objects
predicate shadowsBuiltin(Name variableNode, string builtinIdentifier, Function parentFunction, int lineNumber) {
  // Check if the name node defines a local variable that matches a built-in name
  exists(LocalVariable localVariable |
    variableNode.defines(localVariable) and
    localVariable.getId() = builtinIdentifier and
    exists(Builtin::builtin(localVariable.getId()))
  ) and
  // Get the scope and line number information
  variableNode.getScope() = parentFunction and
  variableNode.getLocation().getStartLine() = lineNumber and
  // Exclude cases that are safe to shadow
  not isSafeToShadow(builtinIdentifier)
}

// Predicate to find the first occurrence of a built-in being shadowed in a scope
predicate isFirstShadow(Name variableNode, string builtinIdentifier) {
  exists(Scope variableScope, int firstShadowLine |
    // Find all shadows in the scope and determine the first one
    shadowsBuiltin(variableNode, builtinIdentifier, variableScope, firstShadowLine) and
    firstShadowLine = min(int line | shadowsBuiltin(_, builtinIdentifier, variableScope, line))
  )
}

// Main query: Find the first local variables in each scope that shadow built-in objects
from Name variableNode, string builtinIdentifier
where isFirstShadow(variableNode, builtinIdentifier)
select variableNode, "Local variable '" + builtinIdentifier + "' shadows a built-in object."