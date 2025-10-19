/**
 * @name Weak elliptic curve
 * @description Identifies the use of elliptic curve cryptographic algorithms that are either unrecognized or known to be weak.
 *              This query helps prevent security vulnerabilities by flagging curves that do not meet security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// List of approved secure elliptic curves
string secureCurve() {
  result = 
    [
      "SECP256R1", "PRIME256V1",  // P-256 curves
      "SECP384R1",                // P-384 curve
      "SECP521R1",                // P-521 curve
      "ED25519",                  // Ed25519 curve
      "X25519"                    // X25519 curve
    ]
}

from EllipticCurveAlgorithm curveImpl, string securityAlert, string curveName
where
  // Extract the curve name from the implementation
  curveName = curveImpl.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    (curveName = unknownAlgorithm() and securityAlert = "Use of unrecognized curve algorithm.")
    or
    // Case 2: Recognized but weak curve algorithm
    (curveName != unknownAlgorithm() and 
     not curveName = secureCurve() and 
     securityAlert = "Use of weak curve algorithm " + curveName + ".")
  )
select curveImpl, securityAlert