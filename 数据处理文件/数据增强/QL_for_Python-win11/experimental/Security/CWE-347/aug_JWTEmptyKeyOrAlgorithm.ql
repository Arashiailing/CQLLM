/**
 * @name JWT encoding using empty key or algorithm
 * @description Detects JWT token encodings that utilize an empty secret key or 
 *              unspecified algorithm, creating potential security vulnerabilities
 *              in token validation mechanisms.
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

// Define variables representing JWT encoding operations and the vulnerable component
from JwtEncoding tokenEncoding, string vulnerableComponent
where
  // First case: Algorithm component is empty or None
  (vulnerableComponent = "algorithm" and isEmptyOrNone(tokenEncoding.getAlgorithm()))
  or
  // Second case: Key component is empty or None
  (vulnerableComponent = "key" and isEmptyOrNone(tokenEncoding.getKey()))
select tokenEncoding, "This JWT encoding has an empty " + vulnerableComponent + ", potentially compromising token security."