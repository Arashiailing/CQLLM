/**
 * @name Weak elliptic curve detection
 * @description Detects cryptographic operations using elliptic curve algorithms that are either unrecognized or classified as weak/insecure
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string securityAlert, string curveName
where
  // Extract the curve name from the elliptic curve cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Condition 1: The curve algorithm is not recognized
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Condition 2: The curve algorithm is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName in [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, securityAlert