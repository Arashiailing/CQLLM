/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations utilizing empty cryptographic keys or algorithms,
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

// Detect JWT encoding operations with vulnerable parameter configurations
from JwtEncoding jwtOperation, string vulnerableParameter
where
  // First vulnerability case: Empty algorithm specification
  (
    vulnerableParameter = "algorithm" and
    isEmptyOrNone(jwtOperation.getAlgorithm())
  )
  or
  // Second vulnerability case: Empty key specification
  (
    vulnerableParameter = "key" and
    isEmptyOrNone(jwtOperation.getKey())
  )
select jwtOperation, "This JWT encoding uses an empty " + vulnerableParameter + " parameter."