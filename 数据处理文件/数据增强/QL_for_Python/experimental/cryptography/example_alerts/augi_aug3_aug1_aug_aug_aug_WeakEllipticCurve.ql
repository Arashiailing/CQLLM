/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms
 *              which are either unrecognized or deemed cryptographically weak, potentially
 *              compromising the application's security posture.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoCurveInstance, string alertMessage, string curveName
where
  // Extract the curve name from the cryptographic implementation
  curveName = cryptoCurveInstance.getCurveName() and
  (
    // Case 1: The curve algorithm is not recognized
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but cryptographically weak
    curveName != unknownAlgorithm() and
    not curveName = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoCurveInstance, alertMessage