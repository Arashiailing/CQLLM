/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms
 *              which are either unrecognized or deemed cryptographically insecure,
 *              potentially introducing security vulnerabilities in the application.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define the collection of cryptographically secure elliptic curves
string trustedCurve() {
  result = 
    "SECP256R1" or result = "PRIME256V1" or  // P-256 curves
    result = "SECP384R1" or                  // P-384 curve
    result = "SECP521R1" or                  // P-521 curve
    result = "ED25519" or                    // Ed25519 curve
    result = "X25519"                        // X25519 curve
}

from EllipticCurveAlgorithm curveImpl, string securityAlert, string curveName
where
  // Retrieve the curve name from the elliptic curve implementation
  curveName = curveImpl.getCurveName() and
  (
    // Scenario 1: Check for unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Check for recognized but cryptographically weak curve algorithm
    curveName != unknownAlgorithm() and
    not curveName = trustedCurve() and
    securityAlert = "Use of weak curve algorithm " + curveName + "."
  )
select curveImpl, securityAlert