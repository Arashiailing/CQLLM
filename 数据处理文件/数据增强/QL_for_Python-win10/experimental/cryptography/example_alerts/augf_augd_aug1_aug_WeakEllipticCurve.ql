/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations using elliptic curve algorithms that are
 *              either unrecognized or considered weak based on security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define a list of approved secure elliptic curves based on security standards
string approvedSecureCurve() {
  result = ["SECP256R1", "PRIME256V1", // P-256 curves
            "SECP384R1",              // P-384 curve
            "SECP521R1",              // P-521 curve
            "ED25519",                // Ed25519 curve
            "X25519"]                 // X25519 curve
}

from EllipticCurveAlgorithm ellipticCurveOperation, string securityWarning
where
  // Extract the curve name from the elliptic curve operation
  exists(string curveName |
    curveName = ellipticCurveOperation.getCurveName() and
    (
      // Check for unrecognized curve algorithms
      curveName = unknownAlgorithm() and
      securityWarning = "Use of unrecognized curve algorithm."
      or
      // Check for recognized but weak curve algorithms
      curveName != unknownAlgorithm() and
      not curveName = approvedSecureCurve() and
      securityWarning = "Use of weak curve algorithm " + curveName + "."
    )
  )
select ellipticCurveOperation, securityWarning