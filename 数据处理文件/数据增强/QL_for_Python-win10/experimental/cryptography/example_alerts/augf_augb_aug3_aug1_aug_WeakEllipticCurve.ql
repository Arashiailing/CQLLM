/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations using elliptic curve algorithms that are either
 *              unrecognized or classified as weak according to security standards.
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
  // Retrieve the curve identifier from the cryptographic operation
  curveName = cryptoOperation.getCurveName()
  and
  // Define secure curve standards
  exists(string secureCurve | 
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Case 1: Unrecognized curve algorithm
    curveName = unknownAlgorithm()
    and warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but insecure curve algorithm
    curveName != unknownAlgorithm()
    and curveName != secureCurve
    and warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, warningMessage