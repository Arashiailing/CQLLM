/**
 * @name Local variable shadows builtin object
 * @description Identifies local variables that have the same name as built-in objects,
 *              which makes the built-in object inaccessible within the current scope
 *              and reduces code clarity.
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

// Predicate that checks if a variable identifier is in the allowed list
// (names that can safely shadow built-ins without causing confusion)
predicate isAllowedName(string identifier) {
  identifier in [
      /* Built-ins that are rarely used and unlikely to cause confusion */
      "iter", "next", "input", "file", "apply", "slice", "buffer", "coerce", "intern", "exit",
      "quit", "license",
      /* Short identifiers or those difficult to avoid in practice */
      "dir", "id", "max", "min", "sum", "cmp", "chr", "ord", "bytes", "_",
    ]
}

// Predicate to verify if a name element represents a local variable
// that shadows a built-in object
predicate shadowsBuiltin(Name nameElement, string identifier, Function functionScope, int lineNumber) {
  exists(LocalVariable localVarRef |
    nameElement.defines(localVarRef) and // Confirm the name element defines a local variable
    localVarRef.getId() = identifier and // Verify the local variable's identifier matches
    exists(Builtin::builtin(localVarRef.getId())) // Ensure the identifier corresponds to a built-in
  ) and
  nameElement.getScope() = functionScope and // Get the enclosing function scope
  nameElement.getLocation().getStartLine() = lineNumber and // Extract the line number
  not isAllowedName(identifier) // Exclude identifiers that are in the allowed list
}

// Predicate to find the initial occurrence of a variable shadowing a built-in
// within a specific scope
predicate isFirstShadowing(Name nameElement, string identifier) {
  exists(int firstOccurrence, Scope enclosingScope |
    shadowsBuiltin(nameElement, identifier, enclosingScope, firstOccurrence) and // Check for shadowing
    firstOccurrence = min(int line | shadowsBuiltin(_, identifier, enclosingScope, line)) // Find earliest occurrence
  )
}

// Main query: Locate all primary instances of local variables that shadow built-in objects
from Name nameElement, string identifier
where isFirstShadowing(nameElement, identifier) // Filter for initial shadowing instances
select nameElement, "Local variable '" + identifier + "' shadows a builtin variable." // Report the issue