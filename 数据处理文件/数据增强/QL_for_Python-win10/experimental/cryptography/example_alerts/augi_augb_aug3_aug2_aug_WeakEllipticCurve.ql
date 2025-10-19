/**
 * @name Weak elliptic curve detection
 * @description Identifies cryptographic implementations that utilize elliptic curve algorithms
 *              which are either unrecognized or classified as weak according to security standards
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string alertMessage, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve operation
  curveIdentifier = ellipticCurveOp.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized by our analysis
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ] and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOp, alertMessage