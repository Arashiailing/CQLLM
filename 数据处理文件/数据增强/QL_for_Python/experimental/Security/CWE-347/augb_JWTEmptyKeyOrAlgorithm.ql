/**
 * @name JWT encoding using empty key or algorithm
 * @description Detects JWT token encodings that utilize empty secrets or algorithms.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import necessary modules for analysis
import python  // Python language support
import experimental.semmle.python.Concepts  // Experimental Python concepts
import experimental.semmle.python.frameworks.JWT  // JWT framework analysis

from JwtEncoding jwtOp, string vulnerableComponent
where
  // Case 1: Empty algorithm vulnerability
  (vulnerableComponent = "algorithm" and isEmptyOrNone(jwtOp.getAlgorithm()))
  or
  // Case 2: Empty key vulnerability
  (vulnerableComponent = "key" and isEmptyOrNone(jwtOp.getKey()))
select jwtOp, "This JWT encoding has an empty " + vulnerableComponent + "."