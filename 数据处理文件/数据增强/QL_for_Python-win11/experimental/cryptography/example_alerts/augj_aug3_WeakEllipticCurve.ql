/**
 * @name Weak elliptic curve
 * @description Identifies the use of unapproved or weak elliptic curve cryptography algorithms.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Retrieves a list of cryptographically secure elliptic curve algorithms.
 * These curves are considered strong and approved for security-sensitive applications.
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
 * Detects the use of weak or unrecognized elliptic curve algorithms.
 * The query identifies two types of security issues:
 * 1. Use of unrecognized/unknown curve algorithms
 * 2. Use of known but cryptographically weak curve algorithms
 */
from EllipticCurveAlgorithm ellipticCurveInstance, string securityWarning, string curveIdentifier
where
  // Extract the curve name from the elliptic curve algorithm instance
  curveIdentifier = ellipticCurveInstance.getCurveName() and
  (
    // Case 1: Detect unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: Detect weak curve algorithms that are not in the approved list
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier = getApprovedEllipticCurves() and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveInstance, securityWarning