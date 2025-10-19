/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Identifies elliptic curve cryptography implementations that use either
 *              unrecognized algorithms or known weak curves, potentially compromising security.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecImplementation, string warningText, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic implementation
  curveIdentifier = ecImplementation.getCurveName() and
  (
    // Case 1: Unrecognized algorithm
    curveIdentifier = unknownAlgorithm() and
    warningText = "Use of unrecognized curve algorithm."
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
    warningText = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ecImplementation, warningText