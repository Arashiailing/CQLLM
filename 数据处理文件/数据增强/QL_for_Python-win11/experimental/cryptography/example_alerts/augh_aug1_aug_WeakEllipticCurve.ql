/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations that employ elliptic curve algorithms which are
 *              either unrecognized or classified as weak based on established security guidelines.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string alertText, string curveIdentifier
where
  curveIdentifier = ellipticCurveUsage.getCurveName() and
  (
    // Scenario 1: Curve algorithm is unrecognized
    curveIdentifier = unknownAlgorithm() and
    alertText = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Curve algorithm is recognized but not in the approved secure curves list
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertText = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveUsage, alertText