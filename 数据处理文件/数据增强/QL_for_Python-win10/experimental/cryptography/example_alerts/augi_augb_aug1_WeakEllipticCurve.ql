/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Identifies elliptic curve cryptographic implementations that are either
 *              unrecognized or classified as weak, potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoImplementation, string securityWarning, string curveIdentifier
where
  // Retrieve the identifier/name of the elliptic curve from the cryptographic implementation
  curveIdentifier = cryptoImplementation.getCurveName() and
  (
    // Detection case 1: The algorithm is unrecognized by the system
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Detection case 2: The algorithm is recognized but classified as weak/insecure
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Diffie-Hellman using Curve25519)
      ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoImplementation, securityWarning