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

from EllipticCurveAlgorithm cryptoOperation, string warningMessage, string ellipticCurveName
where
  // First, extract the curve name from the cryptographic operation
  ellipticCurveName = cryptoOperation.getCurveName() and
  (
    // Case 1: The curve algorithm is unrecognized by the system
    ellipticCurveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but not in the approved secure list
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select cryptoOperation, warningMessage