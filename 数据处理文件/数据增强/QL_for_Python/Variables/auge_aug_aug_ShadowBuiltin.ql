/**
 * @name Local variable shadows built-in object
 * @description Identifies local variables that override built-in objects, making them 
 *              inaccessible in the current scope and degrading code readability.
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
      /* Built-ins that are rarely used and pose low confusion risk */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common short names or unavoidable identifiers in code */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate that detects local variables shadowing built-in objects
predicate shadowsBuiltin(Name identifierNode, string builtinName, Function containingFunction, int lineNumber) {
  exists(LocalVariable localVar |
    identifierNode.defines(localVar) and // Confirm the name node defines a local variable
    localVar.getId() = builtinName and // Match the variable name
    exists(Builtin::builtin(localVar.getId())) // Verify it shadows a built-in
  ) and
  identifierNode.getScope() = containingFunction and // Get the enclosing function scope
  identifierNode.getLocation().getStartLine() = lineNumber and // Extract the source line number
  not isSafeToShadow(builtinName) // Exclude cases that are safe to shadow
}

// Predicate to find the first occurrence of a built-in being shadowed in a scope
predicate isFirstShadow(Name identifierNode, string builtinName) {
  exists(Scope scope, int firstLine |
    shadowsBuiltin(identifierNode, builtinName, scope, firstLine) and
    firstLine = min(int line | shadowsBuiltin(_, builtinName, scope, line))
  )
}

// Main query: Find the first local variables in each scope that shadow built-in objects
from Name identifierNode, string builtinName
where isFirstShadow(identifierNode, builtinName)
select identifierNode, "Local variable '" + builtinName + "' shadows a built-in object."