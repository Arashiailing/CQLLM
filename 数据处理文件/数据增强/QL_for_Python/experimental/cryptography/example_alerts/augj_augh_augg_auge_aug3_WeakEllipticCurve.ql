/**
 * @name Weak elliptic curve detection
 * @description Identifies cryptographic implementations using elliptic curves that are either unapproved or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Provides a collection of cryptographically strong and approved elliptic curve algorithms.
 * These curves meet current security standards for cryptographic operations.
 */
string getSecureEllipticCurveAlgorithms() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // NIST P-256 curves
      "SECP384R1",               // NIST P-384 curve
      "SECP521R1",               // NIST P-521 curve
      "ED25519",                 // EdDSA using Curve25519
      "X25519"                   // Elliptic Curve Diffie-Hellman using Curve25519
    ]
}

/**
 * Identifies implementations of weak or unrecognized elliptic curve algorithms.
 * Generates security alerts for any code utilizing non-approved elliptic curves.
 */
from EllipticCurveAlgorithm cryptoCurveImpl, string securityAlert, string curveName
where
  // Extract the elliptic curve identifier from the implementation
  curveName = cryptoCurveImpl.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Weak curve algorithms (those not in the approved list)
    curveName != unknownAlgorithm() and
    not curveName = getSecureEllipticCurveAlgorithms() and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoCurveImpl, securityAlert