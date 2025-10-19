/**
 * @name Local variable shadows built-in object
 * @description Detects local variables that override built-in objects, rendering them 
 *              inaccessible within the current scope and reducing code clarity.
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

// Predicate that defines variable names allowed to shadow built-ins without introducing ambiguity
predicate isAllowedShadowing(string variableName) {
  variableName in [
      // Infrequently used built-ins with minimal risk of confusion
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      // Commonly used short names or identifiers that are difficult to avoid
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate that identifies local variables that shadow built-in objects
predicate variableShadowsBuiltin(Name nodeName, string variableName, Function scopeContainer, int lineNumber) {
  exists(LocalVariable localVar |
    nodeName.defines(localVar) and // Confirm the name node defines a local variable
    localVar.getId() = variableName and // Ensure variable identifier matches
    exists(Builtin::builtin(localVar.getId())) // Verify collision with a built-in
  ) and
  nodeName.getScope() = scopeContainer and // Capture the enclosing function scope
  nodeName.getLocation().getStartLine() = lineNumber and // Retrieve the source line number
  not isAllowedShadowing(variableName) // Filter out permitted shadowing instances
}

// Predicate that identifies the first occurrence of built-in shadowing within a specific scope
predicate isFirstOccurrenceInScope(Name nodeName, string variableName) {
  exists(Scope variableScope, int earliestLine |
    variableShadowsBuiltin(nodeName, variableName, variableScope, earliestLine) and
    earliestLine = min(int line | variableShadowsBuiltin(_, variableName, variableScope, line))
  )
}

// Main query: Identify initial local variables that shadow built-in objects
from Name nodeName, string variableName
where isFirstOccurrenceInScope(nodeName, variableName)
select nodeName, "Local variable '" + variableName + "' shadows a built-in object."