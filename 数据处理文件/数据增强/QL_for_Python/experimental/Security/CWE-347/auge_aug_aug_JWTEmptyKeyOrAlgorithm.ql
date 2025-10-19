/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encoding operations that utilize empty cryptographic keys or algorithms,
 *              potentially causing security weaknesses during token validation.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import necessary Python analysis libraries
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Find JWT encoding calls that have security issues with parameters
from JwtEncoding jwtEncodeCall, string weakParam
where
  // Detect empty algorithm parameter
  (weakParam = "algorithm" and isEmptyOrNone(jwtEncodeCall.getAlgorithm()))
  or
  // Detect empty key parameter
  (weakParam = "key" and isEmptyOrNone(jwtEncodeCall.getKey()))
select jwtEncodeCall, "This JWT encoding uses an empty " + weakParam + " parameter."