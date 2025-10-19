/**
 * @name Weak elliptic curve detection
 * @description Detects cryptographic implementations employing elliptic curve algorithms
 *              that are either unknown or identified as having insufficient security strength.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveAlgorithmUsage, string warningMessage, string algorithmIdentifier
where
  algorithmIdentifier = curveAlgorithmUsage.getCurveName()
  and
  (
    // Case 1: Unrecognized curve algorithm
    algorithmIdentifier = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
    algorithmIdentifier != unknownAlgorithm() and
    not algorithmIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + algorithmIdentifier + "."
  )
select curveAlgorithmUsage, warningMessage