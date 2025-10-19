/**
 * @name Weak elliptic curve
 * @description Identifies the use of cryptographic elliptic curve algorithms that are either unapproved 
 *              or known to be weak, potentially compromising the security of the system.
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
  curveName = cryptoOperation.getCurveName() and
  (
    // Case 1: Unrecognized algorithm
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm
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