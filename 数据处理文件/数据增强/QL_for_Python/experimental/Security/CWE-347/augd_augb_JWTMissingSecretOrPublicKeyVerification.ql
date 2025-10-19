/**
 * @name JWT missing secret or public key verification
 * @description Detects JWT decoding operations that lack cryptographic verification using a secret key or public key,
 *              potentially allowing unauthorized access through tampered tokens.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// Import required Python analysis libraries and security concept models
import python
import experimental.semmle.python.Concepts

// Identify JWT decoding operations that bypass signature verification
from JwtDecoding insecureJwtOperation
// Filter criteria: select only those JWT decoding instances that do not perform signature validation
where not insecureJwtOperation.verifiesSignature()
// Result output: JWT payload along with corresponding security warning message
select insecureJwtOperation.getPayload(), "is not verified with a cryptographic secret or public key."