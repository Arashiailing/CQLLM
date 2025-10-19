/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations that utilize elliptic curves which are either
 *              unrecognized by the system or known to be cryptographically weak. Such implementations
 *              may introduce security vulnerabilities due to inadequate key strength or
 *              potential backdoors in the curve parameters.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveOperation, string warningMessage, string curveIdentifier
where
  // Extract the identifier of the elliptic curve used in the cryptographic operation
  curveIdentifier = curveOperation.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select curveOperation, warningMessage