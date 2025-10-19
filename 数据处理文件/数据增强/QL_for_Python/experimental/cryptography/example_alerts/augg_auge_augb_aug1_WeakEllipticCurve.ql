/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Detects elliptic curve cryptographic implementations that utilize either
 *              unrecognized algorithms or known weak curves, which may introduce security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoCurveImpl, string securityAlert, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic implementation
  curveIdentifier = cryptoCurveImpl.getCurveName() and
  (
    // Check for unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Evaluate recognized but potentially weak curve algorithms
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
select cryptoCurveImpl, securityAlert