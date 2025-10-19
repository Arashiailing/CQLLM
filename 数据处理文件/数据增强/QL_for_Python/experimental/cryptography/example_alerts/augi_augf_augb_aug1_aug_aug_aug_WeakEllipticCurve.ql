/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms
 *              that are either unrecognized or classified as cryptographically weak,
 *              which could introduce security vulnerabilities in applications.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImpl, string alertMsg, string curveIdentifier
where
  // Define the collection of cryptographically approved elliptic curves
  exists(string approvedCurve |
    approvedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curve variants
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 signature scheme
      "X25519"                  // X25519 key exchange
    ]
  |
    // Retrieve the curve identifier from the implementation
    curveIdentifier = curveImpl.getCurveName() and
    (
      // Case 1: Unrecognized curve algorithm detected
      curveIdentifier = unknownAlgorithm() and
      alertMsg = "Use of unrecognized curve algorithm."
      or
      // Case 2: Recognized but cryptographically weak curve algorithm
      curveIdentifier != unknownAlgorithm() and
      not curveIdentifier = approvedCurve and
      alertMsg = "Use of weak curve algorithm " + curveIdentifier + "."
    )
  )
select curveImpl, alertMsg