/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms that are either
 *              unauthorized or considered cryptographically weak, which may lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string securityAlert, string curveName
where
  // Retrieve the curve name from the elliptic curve cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: Check for unrecognized/unknown curve algorithms
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Check for recognized but cryptographically weak curve algorithms
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves (NIST P-256)
        "SECP384R1",              // P-384 curve (NIST P-384)
        "SECP521R1",              // P-521 curve (NIST P-521)
        "ED25519",                // Ed25519 curve (EdDSA using Curve25519)
        "X25519"                  // X25519 curve (Elliptic Curve Diffie-Hellman using Curve25519)
      ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, securityAlert