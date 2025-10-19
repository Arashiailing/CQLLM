/**
 * @name JWT encoding with empty key or algorithm
 * @description Detects JWT token encoding operations using empty cryptographic keys or algorithms,
 *              which could compromise token validation security.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import core Python analysis libraries
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Identify JWT encoding operations with vulnerable parameters
from JwtEncoding jwtEncoding, string vulnerableParam
where
  // Case 1: Empty algorithm parameter
  (
    vulnerableParam = "algorithm" and
    isEmptyOrNone(jwtEncoding.getAlgorithm())
  )
  or
  // Case 2: Empty key parameter
  (
    vulnerableParam = "key" and
    isEmptyOrNone(jwtEncoding.getKey())
  )
select jwtEncoding, "This JWT encoding uses an empty " + vulnerableParam + " parameter."