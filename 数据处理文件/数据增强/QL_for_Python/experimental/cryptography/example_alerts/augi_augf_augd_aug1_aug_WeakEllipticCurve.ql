/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations using elliptic curve algorithms that are
 *              either unrecognized or classified as weak according to security standards.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define a list of cryptographically secure elliptic curves
// based on industry security standards
string approvedSecureCurve() {
  result = ["SECP256R1", "PRIME256V1", // NIST P-256 curves
            "SECP384R1",              // NIST P-384 curve
            "SECP521R1",              // NIST P-521 curve
            "ED25519",                // EdDSA signature curve
            "X25519"]                 // ECDH key agreement curve
}

from EllipticCurveAlgorithm cryptoOperation, string warningMessage
where
  // Extract curve identifier from the cryptographic operation
  exists(string curveIdentifier |
    curveIdentifier = cryptoOperation.getCurveName() and
    (
      // Case 1: Unrecognized curve algorithm
      curveIdentifier = unknownAlgorithm() and
      warningMessage = "Use of unrecognized curve algorithm."
      or
      // Case 2: Recognized but weak curve algorithm
      curveIdentifier != unknownAlgorithm() and
      not curveIdentifier = approvedSecureCurve() and
      warningMessage = "Use of weak curve algorithm " + curveIdentifier + "."
    )
  )
select cryptoOperation, warningMessage