/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic implementations utilizing elliptic curve algorithms 
 *              that are either unapproved or considered cryptographically weak, which may 
 *              introduce security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string alertMessage, string curveIdentifier
where
  // Define the set of cryptographically approved elliptic curves
  exists(string approvedCurve |
    approvedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the cryptographic operation
    curveIdentifier = cryptoOperation.getCurveName() and
    (
      // Scenario 1: Detection of an unrecognized curve algorithm
      curveIdentifier = unknownAlgorithm() and
      alertMessage = "Use of unrecognized curve algorithm."
      or
      // Scenario 2: Detection of a recognized but cryptographically weak curve algorithm
      curveIdentifier != unknownAlgorithm() and
      not curveIdentifier = approvedCurve and
      alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
    )
  )
select cryptoOperation, alertMessage