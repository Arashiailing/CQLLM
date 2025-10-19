/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Detects cryptographic implementations that utilize elliptic curve algorithms
 *              which are either unauthorized or considered cryptographically weak, potentially
 *              compromising system security.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string alertMessage, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic operation
  curveIdentifier = ellipticCurveUsage.getCurveName() and
  (
    // Case 1: Identify implementations using unknown/unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Detected usage of unrecognized elliptic curve algorithm."
    or
    // Case 2: Identify implementations using recognized but cryptographically inadequate curves
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        // List of cryptographically secure elliptic curves
        "SECP256R1", "PRIME256V1", // P-256 curves (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Elliptic Curve Diffie-Hellman using Curve25519)
      ] and
    alertMessage = "Detected usage of weak elliptic curve algorithm: " + curveIdentifier + "."
  )
select ellipticCurveUsage, alertMessage