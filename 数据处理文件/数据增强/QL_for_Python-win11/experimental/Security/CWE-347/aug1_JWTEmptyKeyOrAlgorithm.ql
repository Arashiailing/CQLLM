/**
 * @name JWT encoding using empty key or algorithm
 * @description Identifies security vulnerabilities where JWT tokens are encoded with empty secrets or missing algorithms.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-empty-secret-or-algorithm
 * @tags security
 *       experimental
 */

// Import required Python analysis modules and JWT framework detection capabilities
import python
import experimental.semmle.python.Concepts
import experimental.semmle.python.frameworks.JWT

from JwtEncoding jwtEncodingOperation, string insecureParameter  // Identify JWT encoding operations and their vulnerable parameters
where
  // Check for empty or missing algorithm in JWT encoding
  (insecureParameter = "algorithm" and 
   isEmptyOrNone(jwtEncodingOperation.getAlgorithm()))
  or
  // Check for empty or missing key in JWT encoding
  (insecureParameter = "key" and 
   isEmptyOrNone(jwtEncodingOperation.getKey()))
select jwtEncodingOperation, "This JWT encoding has an empty " + insecureParameter + "."  // Report the vulnerable encoding operation with specific parameter issue