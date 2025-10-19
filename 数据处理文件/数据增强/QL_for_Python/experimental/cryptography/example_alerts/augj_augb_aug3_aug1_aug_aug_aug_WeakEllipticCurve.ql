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

from EllipticCurveAlgorithm curveImpl, string securityAlert, string curveIdentifier
where
  // Define the collection of cryptographically trusted elliptic curves
  exists(string trustedCurve |
    trustedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the implementation
    curveIdentifier = curveImpl.getCurveName() and
    (
      // Case 1: Check for unrecognized curve algorithm
      curveIdentifier = unknownAlgorithm() and
      securityAlert = "Use of unrecognized curve algorithm."
      or
      // Case 2: Check for recognized but cryptographically weak curve algorithm
      curveIdentifier != unknownAlgorithm() and
      not curveIdentifier = trustedCurve and
      securityAlert = "Use of weak curve algorithm " + curveIdentifier + "."
    )
  )
select curveImpl, securityAlert