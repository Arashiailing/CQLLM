/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations that employ elliptic curve algorithms which are 
 *              either unrecognized or classified as weak, potentially introducing security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string alertMessage, string curveName
where
  // Retrieve the elliptic curve name from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Condition 1: The curve algorithm is not recognized by the system
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Condition 2: The curve algorithm is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName in
      [
        // List of cryptographically secure elliptic curves
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST)
        "SECP384R1",              // P-384 curve (NIST)
        "SECP521R1",              // P-521 curve (NIST)
        "ED25519",                // Ed25519 curve (EdDSA)
        "X25519"                  // X25519 curve (ECDH)
      ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, alertMessage