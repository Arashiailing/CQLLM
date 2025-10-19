/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations employing elliptic curve algorithms that are either
 *              unapproved or considered cryptographically weak, which could lead to security vulnerabilities.
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
  // Define a collection of cryptographically secure elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve name from the elliptic curve operation
    curveName = ellipticCurveOp.getCurveName() and
    (
      // Detection scenario 1: Operation uses an unrecognized curve algorithm
      curveName = unknownAlgorithm() and
      securityAlert = "Use of unrecognized curve algorithm."
      or
      // Detection scenario 2: Operation uses a recognized but weak curve algorithm
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      securityAlert = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveOp, securityAlert