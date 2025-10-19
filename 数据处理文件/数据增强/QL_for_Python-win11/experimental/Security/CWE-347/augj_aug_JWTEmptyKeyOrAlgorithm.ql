/**
 * @name JWT encoding with empty key or algorithm
 * @description Identifies JWT token encodings that employ an empty secret key or
 *              undefined algorithm, which can lead to security weaknesses in
 *              token verification processes.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import necessary modules for Python code analysis and JWT framework identification
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Declare variables representing JWT encoding operations and the identified vulnerability
from JwtEncoding jwtEncodingOperation, string vulnerabilityType
where
  (
    vulnerabilityType = "algorithm" and 
    isEmptyOrNone(jwtEncodingOperation.getAlgorithm())
  )
  or
  (
    vulnerabilityType = "key" and 
    isEmptyOrNone(jwtEncodingOperation.getKey())
  )
select jwtEncodingOperation, "This JWT encoding has an empty " + vulnerabilityType + ", potentially compromising token security."