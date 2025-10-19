/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations using elliptic curve algorithms
 *              that are either unrecognized or classified as weak per security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string warningMessage, string curveName
where
  // Extract curve identifier for analysis
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm detected
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but insecure curve algorithm
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, warningMessage