/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations utilizing empty cryptographic keys or algorithms,
 *              potentially introducing security vulnerabilities during token verification.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import Python analysis modules required for JWT security analysis
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Detect JWT encoding operations with security deficiencies in critical parameters
from JwtEncoding jwtEncode, string paramName
where
  // Case 1: Algorithm parameter is empty or None
  (paramName = "algorithm" and isEmptyOrNone(jwtEncode.getAlgorithm()))
  or
  // Case 2: Key parameter is empty or None
  (paramName = "key" and isEmptyOrNone(jwtEncode.getKey()))
select jwtEncode, "This JWT encoding uses an empty " + paramName + " parameter."