/**
 * @name Weak elliptic curve
 * @description Detects the utilization of unapproved or vulnerable elliptic curve cryptographic implementations.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecAlgorithm, string alertMessage, string curveIdentifier
where
  // Case 1: Unrecognized curve algorithm
  (
    curveIdentifier = ecAlgorithm.getCurveName() and
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
  )
  or
  // Case 2: Recognized but weak curve algorithm
  (
    curveIdentifier = ecAlgorithm.getCurveName() and
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1",  // P-256 curves
        "SECP384R1",                // P-384 curve
        "SECP521R1",                // P-521 curve
        "ED25519",                  // Ed25519 curve
        "X25519"                    // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ecAlgorithm, alertMessage