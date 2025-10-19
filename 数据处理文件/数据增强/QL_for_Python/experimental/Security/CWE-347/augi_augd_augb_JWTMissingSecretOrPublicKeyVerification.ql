/**
 * @name JWT missing secret or public key verification
 * @description Identifies JWT token decoding operations that skip cryptographic verification using a secret key or public key,
 *              which could lead to unauthorized access via manipulated tokens.
 * @kind problem
 * @problem.severity warning
 * @id py/jwt-missing-verification
 * @tags security
 *       experimental
 *       external/cwe/cwe-347
 */

// Import necessary Python analysis libraries and security concept frameworks
import python
import experimental.semmle.python.Concepts

// Locate JWT decoding operations that do not validate cryptographic signatures
from JwtDecoding unverifiedJwtDecode
where not unverifiedJwtDecode.verifiesSignature()
select unverifiedJwtDecode.getPayload(), "is not verified with a cryptographic secret or public key."