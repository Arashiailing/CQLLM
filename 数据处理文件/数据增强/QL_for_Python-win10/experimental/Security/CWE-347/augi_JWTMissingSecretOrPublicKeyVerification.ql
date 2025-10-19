/**
 * @name JWT missing secret or public key verification
 * @description Detects JWT token decoding operations that lack cryptographic verification using either a secret key or public key.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// Import necessary Python analysis modules for code parsing and security concept detection
import python
import experimental.semmle.python.Concepts

// Identify JWT decoding operations that bypass signature verification
from JwtDecoding insecureJwtOperation
where 
  // Filter for JWT operations that do not perform cryptographic signature validation
  exists(insecureJwtOperation) and
  not insecureJwtOperation.verifiesSignature()
// Output the vulnerable JWT payload with security warning message
select insecureJwtOperation.getPayload(), "is not verified with a cryptographic secret or public key."