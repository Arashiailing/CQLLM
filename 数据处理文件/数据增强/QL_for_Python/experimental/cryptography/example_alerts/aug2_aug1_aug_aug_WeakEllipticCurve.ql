/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Identifies cryptographic implementations employing elliptic curve algorithms that are either
 *              unauthorized or deemed cryptographically insufficient, potentially leading to security breaches.
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
  // Retrieve the elliptic curve name from the cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: Detect usage of unknown/unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Identify usage of recognized but cryptographically weak curve algorithms
    curveName != unknownAlgorithm() and
    not curveName in
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