/**
 * @name Weak elliptic curve
 * @description Detects cryptographic implementations using elliptic curves that are either 
 *              unrecognized or known to be weak, which may lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string alertMessage, string curveName
where
  // Extract the curve name from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Check for unrecognized curve algorithms
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Check for recognized but weak curve algorithms
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, alertMessage