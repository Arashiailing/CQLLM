/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations that utilize empty cryptographic keys or algorithms,
 *              potentially leading to security vulnerabilities during token verification.
 *              Empty algorithms can default to insecure ones, while empty keys can allow
 *              unauthorized token tampering.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import necessary Python analysis modules for JWT security analysis
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Identify JWT encoding operations with security weaknesses in their parameters
from JwtEncoding jwtEncodeOp, string vulnerableParam
where
  // Define conditions for insecure parameters
  (
    // Condition 1: Algorithm parameter is empty or None
    vulnerableParam = "algorithm" and isEmptyOrNone(jwtEncodeOp.getAlgorithm())
  )
  or
  (
    // Condition 2: Key parameter is empty or None
    vulnerableParam = "key" and isEmptyOrNone(jwtEncodeOp.getKey())
  )
select jwtEncodeOp, "This JWT encoding uses an empty " + vulnerableParam + " parameter."