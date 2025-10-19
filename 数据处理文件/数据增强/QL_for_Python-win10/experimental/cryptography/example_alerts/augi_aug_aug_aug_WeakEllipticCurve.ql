/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms 
 *              which are either unauthorized or deemed cryptographically weak, potentially 
 *              leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string securityWarning, string curveName
where
  // Define the set of cryptographically secure elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve name from the elliptic curve cryptographic operation
    curveName = ellipticCurveOp.getCurveName() and
    (
      // Scenario 1: The curve algorithm is not recognized
      curveName = unknownAlgorithm() and
      securityWarning = "Use of unrecognized curve algorithm."
      or
      // Scenario 2: The curve algorithm is recognized but not secure
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      securityWarning = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveOp, securityWarning