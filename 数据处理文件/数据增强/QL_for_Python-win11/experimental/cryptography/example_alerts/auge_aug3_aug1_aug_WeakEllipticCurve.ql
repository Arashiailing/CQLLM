/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations that use elliptic curve algorithms which are either
 *              unrecognized or classified as weak according to established security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOp, string alertMsg, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic operation
  curveIdentifier = cryptoOp.getCurveName() and
  (
    // Check for unrecognized curve algorithms
    curveIdentifier = unknownAlgorithm() and
    alertMsg = "Use of unrecognized curve algorithm."
    or
    // Check for recognized but insecure curve algorithms
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMsg = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoOp, alertMsg