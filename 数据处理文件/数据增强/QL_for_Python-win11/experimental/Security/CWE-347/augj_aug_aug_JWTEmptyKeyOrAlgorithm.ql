/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations using empty cryptographic keys or algorithms,
 *              which can compromise token validation security.
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
from JwtEncoding jwtEncode, string paramName
where
  // Check for empty algorithm parameter
  (
    paramName = "algorithm" and
    isEmptyOrNone(jwtEncode.getAlgorithm())
  )
  or
  // Check for empty key parameter
  (
    paramName = "key" and
    isEmptyOrNone(jwtEncode.getKey())
  )
select jwtEncode, "This JWT encoding uses an empty " + paramName + " parameter."