/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either unrecognized or classified as weak/unsafe.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOperation, string securityAlert, string curveName
where
  // Extract the curve name from the cryptographic operation
  curveName = ellipticCurveOperation.getCurveName() and
  (
    // Scenario 1: Curve algorithm is not recognized/unknown
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Curve algorithm is known but not in the approved secure list
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOperation, securityAlert