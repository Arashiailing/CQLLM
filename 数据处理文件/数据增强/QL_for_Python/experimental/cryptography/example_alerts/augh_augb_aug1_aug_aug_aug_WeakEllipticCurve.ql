/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations that employ elliptic curve algorithms
 *              which are either unapproved or deemed cryptographically insecure, potentially
 *              leading to security weaknesses in the implementation.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoImplementation, string securityWarning, string curveName
where
  // Define the set of cryptographically secure elliptic curve algorithms
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve name from the cryptographic implementation
    curveName = cryptoImplementation.getCurveName() and
    (
      // First condition: Unrecognized curve algorithm detected
      curveName = unknownAlgorithm() and
      securityWarning = "Use of unrecognized curve algorithm."
      or
      // Second condition: Recognized but cryptographically weak curve algorithm detected
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      securityWarning = "Use of weak curve algorithm " + curveName + "."
    )
  )
select cryptoImplementation, securityWarning