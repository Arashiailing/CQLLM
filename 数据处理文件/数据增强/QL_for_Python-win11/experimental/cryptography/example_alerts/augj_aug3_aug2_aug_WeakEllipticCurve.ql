/**
 * @name Weak elliptic curve detection
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either unrecognized or classified as weak
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string securityAlert, string curveName
where
  // Retrieve the curve name from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Scenario 1: Algorithm is unrecognized
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName in [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, securityAlert