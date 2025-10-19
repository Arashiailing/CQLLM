/**
 * @name Weak elliptic curve
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms that are either unrecognized or identified as having insufficient security strength.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveOperation, string securityAlert, string curveName
where
  curveName = curveOperation.getCurveName() and
  (
    // Scenario 1: Algorithm is not recognized by the system
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but classified as weak
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
select curveOperation, securityAlert