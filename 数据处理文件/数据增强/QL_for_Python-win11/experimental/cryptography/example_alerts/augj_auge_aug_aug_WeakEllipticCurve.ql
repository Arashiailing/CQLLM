/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations using elliptic curve algorithms that are either 
 *              unrecognized or considered cryptographically weak, potentially introducing security risks.
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
  // Extract curve identifier from the cryptographic operation
  curveName = ellipticCurveOp.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
    curveName != unknownAlgorithm() and
    not curveName in
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