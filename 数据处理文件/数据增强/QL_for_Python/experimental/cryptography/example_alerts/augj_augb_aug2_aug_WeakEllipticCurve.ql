/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations employing elliptic curve algorithms that are either unrecognized or classified as having weak security properties.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string securityAlert, string curveName
where
  curveName = ellipticCurveUsage.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm detected
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm detected
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveUsage, securityAlert