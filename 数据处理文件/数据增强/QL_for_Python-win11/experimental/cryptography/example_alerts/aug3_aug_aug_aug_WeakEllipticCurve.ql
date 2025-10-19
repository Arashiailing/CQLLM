/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations employing elliptic curve algorithms that are either unapproved 
 *              or deemed cryptographically weak, which may lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ecOperation, string warningMsg, string curveId
where
  // Establish the collection of cryptographically robust elliptic curves
  exists(string strongCurve |
    strongCurve = [
      "SECP256R1", "PRIME256V1", // P-256 curves
      "SECP384R1",              // P-384 curve
      "SECP521R1",              // P-521 curve
      "ED25519",                // Ed25519 curve
      "X25519"                  // X25519 curve
    ]
  |
    // Retrieve the curve identifier from the elliptic curve operation
    curveId = ecOperation.getCurveName() and
    (
      // Scenario 1: Detection of an unrecognized curve algorithm
      curveId = unknownAlgorithm() and
      warningMsg = "Use of unrecognized curve algorithm."
      or
      // Scenario 2: Detection of a recognized but cryptographically weak curve algorithm
      curveId != unknownAlgorithm() and
      not curveId = strongCurve and
      warningMsg = "Use of weak curve algorithm " + curveId + "."
    )
  )
select ecOperation, warningMsg