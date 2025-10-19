/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations utilizing elliptic curves that are either unrecognized or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm algo, string alertMsg, string curveName
where
  (
    // Case 1: Unrecognized curve algorithm
    curveName = algo.getCurveName() and
    curveName = unknownAlgorithm() and
    alertMsg = "Use of unrecognized curve algorithm."
  )
  or
  (
    // Case 2: Recognized but weak curve algorithm
    curveName = algo.getCurveName() and
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMsg = "Use of weak curve algorithm " + curveName + "."
  )
select algo, alertMsg