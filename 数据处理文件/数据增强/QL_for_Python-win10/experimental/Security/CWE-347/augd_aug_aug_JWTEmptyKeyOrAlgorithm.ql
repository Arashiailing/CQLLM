/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations that utilize empty cryptographic keys or algorithms,
 *              potentially introducing security vulnerabilities in token verification.
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

// Find JWT encoding calls with vulnerable parameters
from JwtEncoding jwtEncodeCall, string affectedParam
where
  // Detect empty algorithm parameter
  (affectedParam = "algorithm" and isEmptyOrNone(jwtEncodeCall.getAlgorithm()))
  or
  // Detect empty key parameter
  (affectedParam = "key" and isEmptyOrNone(jwtEncodeCall.getKey()))
select jwtEncodeCall, "This JWT encoding uses an empty " + affectedParam + " parameter."