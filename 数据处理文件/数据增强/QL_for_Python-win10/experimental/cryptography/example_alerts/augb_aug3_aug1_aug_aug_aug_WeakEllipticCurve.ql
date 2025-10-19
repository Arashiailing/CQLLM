/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that utilize elliptic curve algorithms
 *              which are either unrecognized or classified as cryptographically weak,
 *              potentially introducing security vulnerabilities to the application.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm algoInstance, string alertMessage, string curveName
where
  // Define the collection of cryptographically secure elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the implementation
    curveName = algoInstance.getCurveName() and
    (
      // Case 1: Check for unrecognized curve algorithm
      curveName = unknownAlgorithm() and
      alertMessage = "Use of unrecognized curve algorithm."
      or
      // Case 2: Check for recognized but cryptographically weak curve algorithm
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      alertMessage = "Use of weak curve algorithm " + curveName + "."
    )
  )
select algoInstance, alertMessage