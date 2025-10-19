/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations employing elliptic curve algorithms that are
 *              either unidentified or classified as weak, potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string alertMessage, string ellipticCurveIdentifier
where
  // Retrieve the elliptic curve identifier from the cryptographic operation
  ellipticCurveIdentifier = ellipticCurveOp.getCurveName()
  and
  (
    // Case 1: Algorithm is unidentified
    ellipticCurveIdentifier = unknownAlgorithm()
    and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Algorithm is identified but deemed weak
    ellipticCurveIdentifier != unknownAlgorithm()
    and
    not ellipticCurveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ]
    and
    alertMessage = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
  )
select ellipticCurveOp, alertMessage