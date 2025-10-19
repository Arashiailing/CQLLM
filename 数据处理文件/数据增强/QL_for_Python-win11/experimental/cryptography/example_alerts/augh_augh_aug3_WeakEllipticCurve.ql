/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic algorithms that are either unapproved or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

/**
 * Provides a collection of secure and approved elliptic curve algorithms
 * recommended for cryptographic implementations.
 */
string getSecureEllipticCurveList() {
  result =
    [
      "SECP256R1", "PRIME256V1",  // P-256 curves
      "SECP384R1",               // P-384 curve
      "SECP521R1",               // P-521 curve
      "ED25519",                 // Ed25519 curve
      "X25519"                   // X25519 curve
    ]
}

/**
 * Detects weak or unrecognized elliptic curve implementations
 * and generates corresponding security alerts.
 */
from EllipticCurveAlgorithm cryptoAlgorithm, string alertMessage, string curveIdentifier
where
  // Retrieve the identifier of the elliptic curve in use
  curveIdentifier = cryptoAlgorithm.getCurveName() and
  (
    // Scenario 1: Detect algorithms with unrecognized curve identifiers
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Identify weak curve algorithms not present in the approved list
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier = getSecureEllipticCurveList() and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoAlgorithm, alertMessage