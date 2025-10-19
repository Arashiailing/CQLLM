/**
 * @name Weak elliptic curve detection
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms that are either unrecognized or classified as weak based on security standards
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImplementation, string securityWarning, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic implementation
  curveIdentifier = curveImplementation.getCurveName() and
  (
    // Scenario 1: The curve algorithm is not recognized in our security analysis
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: The curve algorithm is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select curveImplementation, securityWarning