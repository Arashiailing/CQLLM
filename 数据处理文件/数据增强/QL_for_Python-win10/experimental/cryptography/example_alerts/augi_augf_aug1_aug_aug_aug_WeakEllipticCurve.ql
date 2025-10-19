/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations employing elliptic curve algorithms
 *              that are either unapproved or considered cryptographically weak, potentially
 *              introducing security vulnerabilities into the system.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string securityAlert, string curveName
where
  // Establish the set of cryptographically approved elliptic curves
  exists(string secureCurve |
    secureCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the cryptographic operation
    curveName = ellipticCurveUsage.getCurveName() and
    (
      // Detection scenario for unrecognized curve algorithms
      curveName = unknownAlgorithm() and
      securityAlert = "Use of unrecognized curve algorithm."
      or
      // Detection scenario for recognized but cryptographically weak curve algorithms
      curveName != unknownAlgorithm() and
      not curveName = secureCurve and
      securityAlert = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveUsage, securityAlert