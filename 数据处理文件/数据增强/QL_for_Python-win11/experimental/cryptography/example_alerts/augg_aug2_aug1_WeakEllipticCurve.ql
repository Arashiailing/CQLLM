/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              unrecognized or known to be weak, which could potentially compromise the system's security.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string warningMessage, string curveName
where
  // Extract the curve name from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Scenario 1: Algorithm is not recognized
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but considered weak
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, warningMessage