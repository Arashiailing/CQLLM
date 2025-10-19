/**
 * @name JWT encoding with empty key or algorithm
 * @description Detects JWT token encoding operations that use empty cryptographic keys or algorithms,
 *              which may lead to security vulnerabilities in token validation.
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

// Identify JWT encoding operations with vulnerable parameters
from JwtEncoding jwtEncodingOperation, string vulnerableParameter
where
  // Case 1: Empty algorithm parameter detected
  (
    vulnerableParameter = "algorithm" and
    isEmptyOrNone(jwtEncodingOperation.getAlgorithm())
  )
  or
  // Case 2: Empty key parameter detected
  (
    vulnerableParameter = "key" and
    isEmptyOrNone(jwtEncodingOperation.getKey())
  )
select jwtEncodingOperation, "This JWT encoding uses an empty " + vulnerableParameter + " parameter."