/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms
 *              which are either unidentified or classified as weak, posing potential security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string securityWarning, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic operation
  curveIdentifier = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: Algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
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
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOp, securityWarning