/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations that utilize empty cryptographic keys or algorithms,
 *              potentially causing security weaknesses in token validation mechanisms.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import Python analysis core libraries
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Detect JWT encoding operations with vulnerable parameters
from JwtEncoding encodingOp, string paramName
where
  // Check for empty algorithm parameter
  (
    paramName = "algorithm" and
    isEmptyOrNone(encodingOp.getAlgorithm())
  )
  or
  // Check for empty key parameter
  (
    paramName = "key" and
    isEmptyOrNone(encodingOp.getKey())
  )
select encodingOp, "This JWT encoding uses an empty " + paramName + " parameter."