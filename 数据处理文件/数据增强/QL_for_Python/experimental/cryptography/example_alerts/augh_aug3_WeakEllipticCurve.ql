/**
 * @name Weak elliptic curve
 * @description Finds uses of cryptography algorithms that are unapproved or otherwise weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Retrieves a list of approved elliptic curve algorithms that are considered secure.
 * These curves are recommended for cryptographic operations.
 */
string getApprovedEllipticCurves() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // P-256 curves
      "SECP384R1",               // P-384 curve
      "SECP521R1",               // P-521 curve
      "ED25519",                 // Ed25519 curve
      "X25519"                   // X25519 curve
    ]
}

/**
 * Identifies weak or unrecognized elliptic curve algorithms in the codebase.
 * Generates appropriate security warnings based on the curve's status.
 */
from EllipticCurveAlgorithm curveAlgorithm, string securityWarning, string ellipticCurveName
where
  // Extract the name of the elliptic curve being used
  ellipticCurveName = curveAlgorithm.getCurveName() and
  (
    // Case 1: Check for unrecognized curve algorithms
    ellipticCurveName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for weak curve algorithms that are not in the approved list
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName = getApprovedEllipticCurves() and
    securityWarning = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select curveAlgorithm, securityWarning