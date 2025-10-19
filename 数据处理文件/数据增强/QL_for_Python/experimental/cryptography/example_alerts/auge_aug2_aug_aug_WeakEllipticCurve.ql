/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              not recognized or deemed cryptographically insecure, which may introduce security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string alertMessage, string curveIdentifier
where
  // Retrieve the elliptic curve identifier from the cryptographic operation
  curveIdentifier = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: The curve algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: The curve algorithm is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOp, alertMessage