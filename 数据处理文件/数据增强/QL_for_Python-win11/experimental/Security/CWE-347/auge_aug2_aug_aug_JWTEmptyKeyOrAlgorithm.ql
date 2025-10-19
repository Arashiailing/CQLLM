/**
 * @name JWT encoding with empty key or algorithm
 * @description Detects JWT token encoding operations that employ empty cryptographic keys or algorithms,
 *              which may introduce security vulnerabilities in token validation processes.
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

// Identify JWT encoding operations with security vulnerabilities
from JwtEncoding jwtEncodeOperation, string vulnerableParameter
where
  // Case 1: Algorithm parameter is empty or None
  (
    vulnerableParameter = "algorithm" and
    isEmptyOrNone(jwtEncodeOperation.getAlgorithm())
  )
  or
  // Case 2: Key parameter is empty or None
  (
    vulnerableParameter = "key" and
    isEmptyOrNone(jwtEncodeOperation.getKey())
  )
select jwtEncodeOperation, "This JWT encoding uses an empty " + vulnerableParameter + " parameter."