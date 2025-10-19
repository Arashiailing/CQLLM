/**
 * @name JWT encoding with empty key or algorithm
 * @description Detects JWT token encoding operations that use empty cryptographic keys or algorithms,
 *              which can lead to security vulnerabilities during token verification.
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

// Identify JWT encoding operations with security weaknesses in their parameters
from JwtEncoding jwtEncodingOperation, string insecureParam
where
  // Check for empty algorithm parameter
  (insecureParam = "algorithm" and isEmptyOrNone(jwtEncodingOperation.getAlgorithm()))
  or
  // Check for empty key parameter
  (insecureParam = "key" and isEmptyOrNone(jwtEncodingOperation.getKey()))
select jwtEncodingOperation, "This JWT encoding uses an empty " + insecureParam + " parameter."