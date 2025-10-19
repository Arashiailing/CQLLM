/**
 * @name Weak elliptic curve detection
 * @description Identifies cryptographic operations using elliptic curve algorithms that are either unrecognized or considered weak
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveUsage, string alertMessage, string curveIdentifier
where
  // Extract curve identifier from cryptographic operation
  curveIdentifier = curveUsage.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
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
select curveUsage, alertMessage