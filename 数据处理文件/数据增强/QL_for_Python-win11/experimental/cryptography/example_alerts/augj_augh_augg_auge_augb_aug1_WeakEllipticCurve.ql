/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Identifies elliptic curve cryptography implementations that are potentially insecure.
 *              This includes implementations using either unrecognized algorithms or curves known
 *              to be weak, both of which can introduce significant security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImpl, string warningMessage, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve implementation
  curveIdentifier = curveImpl.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve is recognized but considered weak
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Diffie-Hellman using Curve25519)
      ] and
    warningMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select curveImpl, warningMessage