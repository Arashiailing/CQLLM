/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms
 *              that are either unrecognized or classified as cryptographically weak,
 *              which may introduce security vulnerabilities in the application.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImplementation, string securityWarning, string ellipticCurveIdentifier
where
  // Define the set of cryptographically approved elliptic curves
  exists(string approvedCurve |
    approvedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve identifier from the implementation
    ellipticCurveIdentifier = curveImplementation.getCurveName() and
    (
      // First scenario: Detection of an unrecognized curve algorithm
      ellipticCurveIdentifier = unknownAlgorithm() and
      securityWarning = "Use of unrecognized curve algorithm."
      or
      // Second scenario: Detection of a recognized but cryptographically weak curve algorithm
      ellipticCurveIdentifier != unknownAlgorithm() and
      not ellipticCurveIdentifier = approvedCurve and
      securityWarning = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
    )
  )
select curveImplementation, securityWarning