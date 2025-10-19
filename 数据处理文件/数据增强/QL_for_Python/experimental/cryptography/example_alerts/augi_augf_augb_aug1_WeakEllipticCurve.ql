/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Identifies implementations of elliptic curve cryptographic algorithms that are either
 *              unrecognized or classified as weak, potentially leading to security vulnerabilities.
 *              This query analyzes curve implementations to detect potentially insecure cryptographic choices.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm vulnerableCurveImpl, string securityAlert, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve implementation
  curveIdentifier = vulnerableCurveImpl.getCurveName() and
  (
    // Case 1: Unrecognized algorithm detected
    curveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm detected
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        // Secure curves: NIST P-256, P-384, P-521, Ed25519, X25519
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST)
        "SECP384R1",              // P-384 curve (NIST)
        "SECP521R1",              // P-521 curve (NIST)
        "ED25519",                // Ed25519 curve (EdDSA)
        "X25519"                  // X25519 curve (ECDH)
      ] and
    securityAlert = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select vulnerableCurveImpl, securityAlert