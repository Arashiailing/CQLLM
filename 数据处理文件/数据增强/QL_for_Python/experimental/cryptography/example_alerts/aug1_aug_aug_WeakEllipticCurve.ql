/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Identifies cryptographic implementations employing elliptic curve algorithms that are either
 *              unauthorized or deemed cryptographically insufficient, potentially leading to security breaches.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecCryptoOperation, string alertMessage, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic operation
  curveIdentifier = ecCryptoOperation.getCurveName() and
  (
    // Case 1: Check for unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for recognized but weak curve algorithms
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
select ecCryptoOperation, alertMessage