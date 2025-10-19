/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              unrecognized or classified as cryptographically weak, which may introduce security vulnerabilities.
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
  // Extract the elliptic curve identifier from the cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Scenario 1: The curve algorithm is unrecognized
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: The curve algorithm is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, securityAlert