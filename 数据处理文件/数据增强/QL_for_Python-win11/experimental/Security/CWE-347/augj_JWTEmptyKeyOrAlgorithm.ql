/**
 * @name JWT encoding using empty key or algorithm
 * @description Detects JWT token encoding operations that use an empty secret key or no algorithm,
 *              which can lead to security vulnerabilities.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import necessary libraries for Python analysis and JWT framework detection
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

from JwtEncoding jwtEncodeOperation, string componentType
where
  // Case 1: Empty algorithm detection
  (
    componentType = "algorithm" and
    isEmptyOrNone(jwtEncodeOperation.getAlgorithm())
  )
  or
  // Case 2: Empty key detection
  (
    componentType = "key" and
    isEmptyOrNone(jwtEncodeOperation.getKey())
  )
select jwtEncodeOperation, "This JWT encoding operation uses an empty " + componentType + ", which may introduce security vulnerabilities."