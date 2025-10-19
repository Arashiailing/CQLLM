/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms
 *              which are either not recognized or considered cryptographically insecure.
 *              Such implementations may lead to security vulnerabilities in the system.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string alertMessage, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve cryptographic operation
  curveIdentifier = cryptoOperation.getCurveName() and
  // Check for either unrecognized/unknown curve algorithms or weak curve algorithms
  (
    // Scenario 1: Unrecognized/unknown curve algorithms
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Recognized but cryptographically weak curve algorithms
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in [
        "SECP256R1", "PRIME256V1", // P-256 curves (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Diffie-Hellman using Curve25519)
      ] and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoOperation, alertMessage