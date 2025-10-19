/**
 * @name JWT encoding using empty key or algorithm
 * @description Identifies JWT token encodings that utilize an empty secret key or 
 *              unspecified algorithm, which may compromise token validation security
 *              by enabling unauthorized token manipulation.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import required libraries for Python code analysis and JWT framework detection
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

// Define variables representing JWT encoding operations and the vulnerable parameter
from JwtEncoding jwtEncodingOperation, string vulnerableParameter
where
  // Case 1: Algorithm parameter is empty or None
  (vulnerableParameter = "algorithm" and isEmptyOrNone(jwtEncodingOperation.getAlgorithm()))
  or
  // Case 2: Key parameter is empty or None
  (vulnerableParameter = "key" and isEmptyOrNone(jwtEncodingOperation.getKey()))
select jwtEncodingOperation, "This JWT encoding has an empty " + vulnerableParameter + ", potentially compromising token security."