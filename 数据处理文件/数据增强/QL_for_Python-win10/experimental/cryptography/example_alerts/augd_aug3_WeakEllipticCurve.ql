/**
 * @name Weak elliptic curve
 * @description Identifies usage of unapproved or weak cryptographic elliptic curve algorithms.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define approved secure elliptic curve algorithms
string getApprovedEllipticCurve() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // NIST P-256 curves
      "SECP384R1",               // NIST P-384 curve
      "SECP521R1",               // NIST P-521 curve
      "ED25519",                 // EdDSA Ed25519 curve
      "X25519"                   // ECDH X25519 curve
    ]
}

// Analyze elliptic curve implementations for security weaknesses
from EllipticCurveAlgorithm curveAlgo, string warningMessage, string usedCurveName
where
  // Extract curve name from algorithm instance
  usedCurveName = curveAlgo.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    usedCurveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Weak curve algorithm
    usedCurveName != unknownAlgorithm() and
    not usedCurveName = getApprovedEllipticCurve() and
    warningMessage = "Use of weak curve algorithm " + usedCurveName + "."
  )
select curveAlgo, warningMessage