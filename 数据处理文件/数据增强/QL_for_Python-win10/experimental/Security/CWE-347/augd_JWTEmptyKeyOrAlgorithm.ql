/**
 * @name JWT encoding using empty key or algorithm
 * @description Detects JWT token encodings that utilize an empty secret key or algorithm,
 *              potentially leading to security vulnerabilities in token validation.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import required libraries for Python security analysis
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

from JwtEncoding jwtTokenOperation, string securityIssue
where
  (securityIssue = "algorithm" and isEmptyOrNone(jwtTokenOperation.getAlgorithm()))
  or
  (securityIssue = "key" and isEmptyOrNone(jwtTokenOperation.getKey()))
select jwtTokenOperation, "This JWT encoding has an empty " + securityIssue + "."