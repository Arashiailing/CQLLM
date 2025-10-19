/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations that utilize elliptic curve algorithms which are either unrecognized or considered weak for security purposes.
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
    // Check for unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Check for recognized but weak curve algorithms
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
select ellipticCurveUsage, securityAlert