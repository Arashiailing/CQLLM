/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Detects the implementation of elliptic curve cryptographic algorithms that are either
 *              unrecognized or classified as weak, which may lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveImpl, string securityAlert, string curveIdentifier
where
  // Extract the curve name from the elliptic curve implementation
  curveIdentifier = ellipticCurveImpl.getCurveName() and
  (
    // Case 1: Unrecognized algorithm
    curveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityAlert = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveImpl, securityAlert