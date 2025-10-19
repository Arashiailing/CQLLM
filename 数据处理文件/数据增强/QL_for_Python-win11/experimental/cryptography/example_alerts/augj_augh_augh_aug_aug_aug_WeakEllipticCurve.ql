/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations employing elliptic curve algorithms
 *              that are either unapproved or deemed cryptographically weak,
 *              which could introduce security vulnerabilities.
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
  // Extract curve identifier from the cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: Unrecognized curve algorithm detected
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Recognized but cryptographically weak curve algorithm detected
    curveName != unknownAlgorithm() and
    not exists(string secureCurve |
      secureCurve = [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ]
    |
      curveName = secureCurve
    ) and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, securityAlert