/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms
 *              which are either not recognized or deemed cryptographically insecure,
 *              potentially leading to security vulnerabilities in the application.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImpl, string warningMsg, string curveId
where
  // Define the set of cryptographically approved elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve identifier from the implementation
    curveId = curveImpl.getCurveName() and
    (
      // First scenario: Detection of an unrecognized curve algorithm
      curveId = unknownAlgorithm() and
      warningMsg = "Use of unrecognized curve algorithm."
      or
      // Second scenario: Detection of a recognized but cryptographically weak curve algorithm
      curveId != unknownAlgorithm() and
      not curveId = secureCurve and
      warningMsg = "Use of weak curve algorithm " + curveId + "."
    )
  )
select curveImpl, warningMsg