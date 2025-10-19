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

from EllipticCurveAlgorithm ellipticCurveOperation, string securityWarning, string ellipticCurveName
where
  // Retrieve the name of the elliptic curve used in the cryptographic operation
  ellipticCurveName = ellipticCurveOperation.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized
    ellipticCurveName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but considered weak
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityWarning = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select ellipticCurveOperation, securityWarning