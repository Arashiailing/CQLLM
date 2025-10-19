/**
 * @name Weak elliptic curve detection
 * @description Identifies cryptographic algorithms using elliptic curves that are either unapproved or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Holds a list of cryptographically strong and approved elliptic curve algorithms.
 * These curves are considered secure for cryptographic operations.
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
 * Reports security warnings for any implementation using non-approved curves.
 */
from EllipticCurveAlgorithm ellipticCurveInstance, string securityWarning, string curveName
where
  // Extract the name of the elliptic curve being used
  curveName = ellipticCurveInstance.getCurveName() and
  (
    // Case 1: Check for completely unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for weak curve algorithms (not in the approved list)
    curveName != unknownAlgorithm() and
    not curveName = getApprovedEllipticCurves() and
    securityWarning = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveInstance, securityWarning