/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms
 *              that are either unrecognized or considered cryptographically weak,
 *              which could introduce security vulnerabilities in the application.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically trusted elliptic curves
string trustedCurve() {
  result = [
    "SECP256R1", "PRIME256V1", // P-256 curves
    "SECP384R1",              // P-384 curve
    "SECP521R1",              // P-521 curve
    "ED25519",                // Ed25519 curve
    "X25519"                  // X25519 curve
  ]
}

from EllipticCurveAlgorithm algoImplementation, string alertMessage, string curveIdentifier
where
  // Extract the curve identifier from the algorithm implementation
  curveIdentifier = algoImplementation.getCurveName() and
  (
    // Case 1: Detection of an unrecognized curve algorithm
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Detection of a recognized but cryptographically weak curve algorithm
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier = trustedCurve() and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select algoImplementation, alertMessage