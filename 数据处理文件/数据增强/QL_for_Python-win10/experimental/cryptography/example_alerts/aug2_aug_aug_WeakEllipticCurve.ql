/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations that employ elliptic curve algorithms which are either 
 *              unrecognized or considered cryptographically weak, potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string securityWarning, string ellipticCurveName
where
  // Extract the elliptic curve name from the cryptographic operation
  ellipticCurveName = cryptoOperation.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    ellipticCurveName = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
    ellipticCurveName != unknownAlgorithm() and
    not ellipticCurveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityWarning = "Use of weak curve algorithm " + ellipticCurveName + "."
  )
select cryptoOperation, securityWarning