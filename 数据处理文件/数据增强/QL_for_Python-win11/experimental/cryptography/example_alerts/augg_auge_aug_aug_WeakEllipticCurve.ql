/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations using elliptic curve algorithms that are either 
 *              unrecognized or cryptographically weak, potentially introducing security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string alertMsg, string curveName
where
  // Extract curve identifier from cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Check for unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    alertMsg = "Use of unrecognized curve algorithm."
    or
    // Check for recognized but weak curve algorithm
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMsg = "Use of weak curve algorithm " + curveName + "."
  )
select ellipticCurveOp, alertMsg