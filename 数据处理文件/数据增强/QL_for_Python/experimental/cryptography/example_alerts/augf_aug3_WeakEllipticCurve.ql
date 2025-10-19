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
 * Retrieves a list of cryptographically secure elliptic curve algorithms
 * that are approved for use in secure systems.
 */
string getApprovedEllipticCurves() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // NIST P-256 curves
      "SECP384R1",               // NIST P-384 curve
      "SECP521R1",               // NIST P-521 curve
      "ED25519",                 // EdDSA Ed25519 curve
      "X25519"                   // ECDH X25519 curve
    ]
}

/**
 * Detects weak or unrecognized elliptic curve algorithms in cryptographic operations.
 */
from EllipticCurveAlgorithm curveAlgorithm, string securityAlert, string ellipticCurveName
where
  // Extract the curve name from the algorithm instance
  ellipticCurveName = curveAlgorithm.getCurveName() and
  (
    // Case 1: Check for unrecognized curve algorithms
    ellipticCurveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for weak curve algorithms not in the approved list
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName = getApprovedEllipticCurves() and
    securityAlert = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select curveAlgorithm, securityAlert