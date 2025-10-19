/**
 * @name Weak elliptic curve
 * @description Detects cryptographic elliptic curve implementations that are either unrecognized 
 *              or classified as weak, which may lead to security vulnerabilities in the system.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string securityAlert, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve operation
  curveIdentifier = ellipticCurveUsage.getCurveName() and
  (
    // Scenario 1: Algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but considered weak
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
select ellipticCurveUsage, securityAlert