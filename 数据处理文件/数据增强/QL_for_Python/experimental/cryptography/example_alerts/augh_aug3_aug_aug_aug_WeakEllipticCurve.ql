/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Detects cryptographic operations using elliptic curve algorithms that are either not approved
 *              or considered cryptographically insecure, potentially introducing security weaknesses.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveOperation, string alertMessage, string curveIdentifier
where
  // Define the set of cryptographically strong elliptic curves
  exists(string approvedCurve |
    approvedCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Extract the curve identifier from the elliptic curve operation
    curveIdentifier = curveOperation.getCurveName() and
    (
      // Case 1: Unrecognized curve algorithm
      curveIdentifier = unknownAlgorithm() and
      alertMessage = "Use of unrecognized curve algorithm."
      or
      // Case 2: Recognized but cryptographically weak curve algorithm
      curveIdentifier != unknownAlgorithm() and
      not curveIdentifier = approvedCurve and
      alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
    )
  )
select curveOperation, alertMessage