/**
 * @name JWT encoding using empty key or algorithm
 * @description Identifies JWT token encodings that employ empty cryptographic secrets or algorithms.
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

from JwtEncoding jwtEncodingOp, string vulnerabilityType
where
  // Scenario 1: Empty algorithm vulnerability
  (vulnerabilityType = "algorithm" and isEmptyOrNone(jwtEncodingOp.getAlgorithm()))
  or
  // Scenario 2: Empty key vulnerability
  (vulnerabilityType = "key" and isEmptyOrNone(jwtEncodingOp.getKey()))
select jwtEncodingOp, "This JWT encoding has an empty " + vulnerabilityType + "."