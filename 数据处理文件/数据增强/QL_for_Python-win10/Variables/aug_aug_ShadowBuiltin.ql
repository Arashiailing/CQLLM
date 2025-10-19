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

// Predicate defining names permitted to shadow built-ins without causing confusion
predicate isPermittedShadowing(string varIdentifier) {
  varIdentifier in [
      /* Rarely used built-ins with low confusion risk */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Common short names or unavoidable identifiers */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate detecting local variables that shadow built-in objects
predicate builtinShadowing(Name nameNode, string varIdentifier, Function enclosingScope, int sourceLine) {
  exists(LocalVariable localVar |
    nameNode.defines(localVar) and // Verify name node defines a local variable
    localVar.getId() = varIdentifier and // Match variable identifier
    exists(Builtin::builtin(localVar.getId())) // Confirm built-in collision
  ) and
  nameNode.getScope() = enclosingScope and // Capture enclosing function scope
  nameNode.getLocation().getStartLine() = sourceLine and // Extract source line number
  not isPermittedShadowing(varIdentifier) // Exclude permitted shadowing cases
}

// Predicate identifying the first occurrence of built-in shadowing in a scope
predicate isFirstShadowingInstance(Name nameNode, string varIdentifier) {
  exists(Scope currentScope, int firstOccurrenceLine |
    builtinShadowing(nameNode, varIdentifier, currentScope, firstOccurrenceLine) and
    firstOccurrenceLine = min(int line | builtinShadowing(_, varIdentifier, currentScope, line))
  )
}

// Main query: Detect initial local variables shadowing built-in objects
from Name nameNode, string varIdentifier
where isFirstShadowingInstance(nameNode, varIdentifier)
select nameNode, "Local variable '" + varIdentifier + "' shadows a built-in object."