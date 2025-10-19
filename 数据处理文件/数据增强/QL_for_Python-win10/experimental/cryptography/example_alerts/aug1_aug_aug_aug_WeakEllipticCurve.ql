/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms 
 *              which are either unapproved or deemed cryptographically insecure, potentially 
 *              leading to security vulnerabilities.
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
  // Establish the collection of cryptographically secure elliptic curves
  exists(string trustedCurve |
    trustedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve name from the elliptic curve operation
    curveName = ellipticCurveOp.getCurveName() and
    (
      // Case 1: Detection of an unrecognized curve algorithm
      curveName = unknownAlgorithm() and
      securityAlert = "Use of unrecognized curve algorithm."
      or
      // Case 2: Detection of a recognized but cryptographically weak curve algorithm
      curveName != unknownAlgorithm() and
      not curveName = trustedCurve and
      securityAlert = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveOp, securityAlert