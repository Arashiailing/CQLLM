/**
 * @name JWT encoding with empty key or algorithm
 * @description This query identifies JWT (JSON Web Token) encoding operations that utilize empty 
 *              cryptographic keys or algorithms. Such misconfigurations can introduce critical 
 *              security weaknesses, allowing attackers to forge tokens or bypass authentication 
 *              mechanisms entirely.
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

// Identify JWT encoding operations with vulnerable parameter configurations
from JwtEncoding jwtEncodingInstance, string vulnerableParamName
where
  // Condition 1: Detect empty algorithm specification
  (
    vulnerableParamName = "algorithm" and
    isEmptyOrNone(jwtEncodingInstance.getAlgorithm())
  )
  or
  // Condition 2: Detect empty cryptographic key
  (
    vulnerableParamName = "key" and
    isEmptyOrNone(jwtEncodingInstance.getKey())
  )
select jwtEncodingInstance, "This JWT encoding uses an empty " + vulnerableParamName + " parameter."