/**
 * @name 'super' in old style class
 * @description Identifies super() function calls within legacy class definitions, 
 *              which are not supported due to the absence of new-style class features.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

/**
 * Detects super() function invocations that are placed inside old-style class definitions.
 * These invocations are invalid because legacy classes lack the infrastructure needed 
 * to support the super() mechanism.
 */
predicate legacyClassSuperCallIssue(Call superCall) {
  // Verify the call targets the 'super' builtin function
  superCall.getFunc().(Name).getId() = "super" and
  // Ensure the call is properly nested within a function and a class
  exists(Function enclosingFunction, ClassObject oldStyleClass |
    // The super invocation must be inside a function
    superCall.getScope() = enclosingFunction and
    // This function must be defined inside a class
    enclosingFunction.getScope() = oldStyleClass.getPyClass() and
    // The class must be successfully analyzed
    not oldStyleClass.failedInference() and
    // Confirm the class is a legacy (old-style) class
    not oldStyleClass.isNewStyle()
  )
}

// Primary query to locate all invalid super() calls in legacy classes
from Call problematicSuperCall
// Apply filter to identify super() calls that violate legacy class constraints
where legacyClassSuperCallIssue(problematicSuperCall)
// Generate the finding with an appropriate error message
select problematicSuperCall, "'super()' will not work in old-style classes."