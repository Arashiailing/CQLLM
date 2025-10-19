/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic implementations that utilize elliptic curve algorithms
 *              which are either not recognized or deemed cryptographically insecure.
 *              Such implementations may introduce security vulnerabilities due to
 *              inadequate cryptographic strength.
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
  // Extract the curve name from the elliptic curve cryptographic operation
  curveName = ellipticCurveOperation.getCurveName() and
  (
    // Scenario 1: The curve algorithm is not recognized
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: The curve algorithm is recognized but cryptographically weak
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
select ellipticCurveOperation, securityAlert