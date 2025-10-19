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
string getApprovedEllipticCurves() {
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
from EllipticCurveAlgorithm curveImplementation, string alertMessage, string algorithmIdentifier
where
  // Extract the elliptic curve identifier from the implementation
  algorithmIdentifier = curveImplementation.getCurveName() and
  (
    // Check for unrecognized curve algorithms
    algorithmIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Check for weak curve algorithms (those not in the approved list)
    algorithmIdentifier != unknownAlgorithm() and
    not algorithmIdentifier = getApprovedEllipticCurves() and
    alertMessage = "Use of weak curve algorithm " + algorithmIdentifier + "."
  )
select curveImplementation, alertMessage