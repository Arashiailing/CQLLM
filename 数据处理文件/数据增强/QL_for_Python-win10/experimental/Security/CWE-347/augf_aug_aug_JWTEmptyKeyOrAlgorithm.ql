/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations that utilize empty cryptographic keys 
 *              or algorithms, potentially introducing security vulnerabilities in token validation.
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

// Detect JWT encoding calls with missing or null security parameters
from JwtEncoding jwtEncodeCall, string vulnParam
where
  // Check for either empty algorithm or key in JWT encoding
  exists(string param |
    (
      param = "algorithm" and isEmptyOrNone(jwtEncodeCall.getAlgorithm()) or
      param = "key" and isEmptyOrNone(jwtEncodeCall.getKey())
    ) and
    vulnParam = param
  )
select jwtEncodeCall, "This JWT encoding uses an empty " + vulnParam + " parameter."