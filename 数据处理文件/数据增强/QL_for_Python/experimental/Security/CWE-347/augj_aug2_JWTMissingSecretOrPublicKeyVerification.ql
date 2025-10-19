/**
 * @name JWT missing secret or public key verification
 * @description Detects JWT decoding operations that lack proper cryptographic verification
 *              using either a secret key or public key, potentially allowing token tampering.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// Import necessary Python analysis libraries for code parsing and security concept evaluation
import python
import experimental.semmle.python.Concepts

// Identify JWT decode operations that fail to perform signature verification
from JwtDecoding unverifiedJwtDecode
// Filter condition: JWT decoding operation lacks cryptographic signature verification
// This indicates a potential security vulnerability where tokens can be forged
where not unverifiedJwtDecode.verifiesSignature()
// Output format: JWT payload location with descriptive security warning message
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."