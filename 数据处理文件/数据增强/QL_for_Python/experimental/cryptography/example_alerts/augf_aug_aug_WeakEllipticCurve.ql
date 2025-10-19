/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations using elliptic curve algorithms that are either unapproved 
 *              or cryptographically weak, which may lead to security vulnerabilities.
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
  // Retrieve the curve identifier from the cryptographic operation
  curveIdentifier = cryptoOperation.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      ["SECP256R1", "PRIME256V1", // P-256 curves
       "SECP384R1",              // P-384 curve
       "SECP521R1",              // P-521 curve
       "ED25519",                // Ed25519 curve
       "X25519"] and              // X25519 curve
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoOperation, alertMessage