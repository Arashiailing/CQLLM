/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              unrecognized or classified as weak according to security best practices.
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
  // Scenario 1: Curve name corresponds to an unrecognized algorithm
  (
    curveName = curveOperation.getCurveName() and
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
  )
  or
  // Scenario 2: Curve name is recognized but not in the approved secure curves list
  (
    curveName != unknownAlgorithm() and
    curveName = curveOperation.getCurveName() and
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