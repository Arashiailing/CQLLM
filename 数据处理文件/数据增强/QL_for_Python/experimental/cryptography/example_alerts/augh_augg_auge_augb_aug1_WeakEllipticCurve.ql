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

from EllipticCurveAlgorithm ellipticCurveImpl, string securityWarning, string curveName
where
  // Retrieve the curve name from the elliptic curve implementation
  curveName = ellipticCurveImpl.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized
    curveName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Diffie-Hellman using Curve25519)
      ] and
    securityWarning = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveImpl, securityWarning