/**
 * @name JWT encoding with empty key or algorithm
 * @description Detects JWT token creation that employs blank cryptographic keys 
 *              or unspecified algorithms, which may lead to security weaknesses 
 *              in token authentication mechanisms.
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

// Identify JWT encoding operations with security deficiencies
from JwtEncoding jwtTokenCreation, string insecureParameter
where
  // Determine if critical security parameters are missing or invalid
  exists(string securityParam |
    (
      securityParam = "algorithm" and isEmptyOrNone(jwtTokenCreation.getAlgorithm()) or
      securityParam = "key" and isEmptyOrNone(jwtTokenCreation.getKey())
    ) and
    insecureParameter = securityParam
  )
select jwtTokenCreation, "This JWT encoding uses an empty " + insecureParameter + " parameter."