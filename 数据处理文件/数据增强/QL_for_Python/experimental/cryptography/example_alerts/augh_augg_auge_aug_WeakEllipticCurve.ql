/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations using elliptic curve algorithms that are either unrecognized or categorized as weak/unsafe.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOperation, string securityAlert, string curveName
where
  // Extract the curve identifier from the cryptographic operation
  curveName = ellipticCurveOperation.getCurveName() and
  (
    // Check for unrecognized/unknown curve algorithm
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Check for recognized but insecure curve algorithm
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
select ellipticCurveOperation, securityAlert