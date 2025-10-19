/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations that employ elliptic curve algorithms
 *              which are either unrecognized or considered cryptographically weak,
 *              potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string securityAlert, string curveName
where
  // Extract the elliptic curve identifier from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
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
select cryptoOperation, securityAlert