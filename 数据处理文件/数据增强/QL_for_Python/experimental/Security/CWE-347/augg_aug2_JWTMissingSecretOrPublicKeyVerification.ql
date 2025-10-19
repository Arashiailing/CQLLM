/**
 * @name JWT missing secret or public key verification
 * @description Detects JWT decoding operations that lack verification using a cryptographic secret or public key.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// Import necessary libraries for Python code analysis and security concepts
import python
import experimental.semmle.python.Concepts

// Identify JWT decoding operations that are not cryptographically verified
from JwtDecoding unverifiedJwtDecode
where 
  // Filter for JWT operations that do not verify the signature with a secret or public key
  not unverifiedJwtDecode.verifiesSignature()
// Output the JWT payload along with a security warning message
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."