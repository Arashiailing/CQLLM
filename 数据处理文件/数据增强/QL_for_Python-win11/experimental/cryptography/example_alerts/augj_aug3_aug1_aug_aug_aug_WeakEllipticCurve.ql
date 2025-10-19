/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that utilize elliptic curve algorithms
 *              which are either unrecognized or classified as cryptographically weak,
 *              potentially introducing security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveImpl, string warningMessage, string curveName
where
  // Define a set of cryptographically secure elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve name from the implementation
    curveName = ellipticCurveImpl.getCurveName() and
    (
      // Case 1: Detect implementations using unrecognized curve algorithms
      curveName = unknownAlgorithm() and
      warningMessage = "Use of unrecognized curve algorithm."
      or
      // Case 2: Detect implementations using recognized but weak curve algorithms
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      warningMessage = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveImpl, warningMessage