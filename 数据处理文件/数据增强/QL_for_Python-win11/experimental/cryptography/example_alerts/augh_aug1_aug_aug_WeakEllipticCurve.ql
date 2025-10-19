/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Detects cryptographic implementations using elliptic curve algorithms
 *              that are either unauthorized or considered cryptographically weak,
 *              potentially leading to security vulnerabilities.
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
  // Extract the curve name from the cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Case 1: Check for unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for recognized but weak curve algorithms
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
select ellipticCurveOp, securityAlert