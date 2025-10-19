/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations that employ elliptic curve algorithms
 *              which are either unrecognized or deemed weak based on established security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveCryptoOperation, string securityAlert, string curveName
where
  // Extract the curve name from the cryptographic operation
  curveName = curveCryptoOperation.getCurveName() and
  (
    // Scenario 1: Unrecognized curve algorithm detected
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Recognized but insecure curve algorithm
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
select curveCryptoOperation, securityAlert