/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Identifies cryptographic implementations utilizing elliptic curve algorithms
 *              that are either unapproved or deemed cryptographically insecure,
 *              which may introduce security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOperation, string securityWarning, string curveIdentifier
where
  // Retrieve the identifier of the elliptic curve from the cryptographic operation
  curveIdentifier = ellipticCurveOperation.getCurveName() and
  (
    // Scenario 1: Detect unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Detect recognized but cryptographically weak curve algorithms
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOperation, securityWarning