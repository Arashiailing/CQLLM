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
predicate legacyClassSuperCallIssue(Call superInvocation) {
  // First, verify the call is to the 'super' builtin function
  superInvocation.getFunc().(Name).getId() = "super" and
  // Then, ensure the call is properly nested within a function and a class
  exists(Function parentFunction, ClassObject legacyClass |
    // The super invocation must be inside a function
    superInvocation.getScope() = parentFunction and
    // This function must be defined inside a class
    parentFunction.getScope() = legacyClass.getPyClass() and
    // The class must be successfully analyzed
    not legacyClass.failedInference() and
    // Finally, confirm the class is a legacy (old-style) class
    not legacyClass.isNewStyle()
  )
}

// Primary query to locate all invalid super() calls in legacy classes
from Call invalidSuperCall
// Apply filter to identify super() calls that violate legacy class constraints
where legacyClassSuperCallIssue(invalidSuperCall)
// Generate the finding with an appropriate error message
select invalidSuperCall, "'super()' will not work in old-style classes."