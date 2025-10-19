/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic implementations that employ elliptic curve algorithms 
 *              which are either unapproved or deemed cryptographically insecure, potentially 
 *              leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveCryptoOperation, string securityWarningMessage, string ellipticCurveIdentifier
where
  // Establish the collection of cryptographically secure elliptic curves
  exists(string approvedCurve |
    approvedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the elliptic curve cryptographic operation
    ellipticCurveIdentifier = curveCryptoOperation.getCurveName() and
    (
      // Case 1: Detection of an unrecognized curve algorithm
      ellipticCurveIdentifier = unknownAlgorithm() and
      securityWarningMessage = "Use of unrecognized curve algorithm."
      or
      // Case 2: Detection of a recognized but cryptographically weak curve algorithm
      ellipticCurveIdentifier != unknownAlgorithm() and
      not ellipticCurveIdentifier = approvedCurve and
      securityWarningMessage = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
    )
  )
select curveCryptoOperation, securityWarningMessage