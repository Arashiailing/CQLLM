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

// Import required modules for Python AST analysis and security concept detection
import python
import experimental.semmle.python.Concepts

// Locate instances of JWT decoding without proper cryptographic verification
from JwtDecoding insecureJwtOperation
where 
  // Exclude JWT operations that perform signature verification with cryptographic keys
  not insecureJwtOperation.verifiesSignature()
// Report the JWT payload location with security advisory message
select insecureJwtOperation.getPayload(), "is not verified with a cryptographic secret or public key."