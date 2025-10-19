/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              not recognized or considered cryptographically weak, potentially introducing security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecOperation, string warningMessage, string curveName
where
  // Extract the curve name from the elliptic curve cryptographic operation
  curveName = ecOperation.getCurveName() and
  (
    // Scenario 1: Algorithm represents an unrecognized/unknown curve
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but uses a cryptographically weak curve
    curveName != unknownAlgorithm() and
    not curveName in
      ["SECP256R1", "PRIME256V1", // P-256 curves
       "SECP384R1",              // P-384 curve
       "SECP521R1",              // P-521 curve
       "ED25519",                // Ed25519 curve
       "X25519"] and              // X25519 curve
    warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select ecOperation, warningMessage