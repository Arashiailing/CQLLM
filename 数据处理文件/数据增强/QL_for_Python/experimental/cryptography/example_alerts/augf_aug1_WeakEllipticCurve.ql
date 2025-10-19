/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either 
 *              unrecognized or classified as weak, which could lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string securityWarning, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve operation
  curveIdentifier = ellipticCurveUsage.getCurveName() and
  (
    // Scenario 1: The curve algorithm is not recognized by the system
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: The curve algorithm is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        // List of approved secure elliptic curves
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST)
        "SECP384R1",              // P-384 curve (NIST)
        "SECP521R1",              // P-521 curve (NIST)
        "ED25519",                // Ed25519 curve (EdDSA)
        "X25519"                  // X25519 curve (ECDH)
      ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveUsage, securityWarning