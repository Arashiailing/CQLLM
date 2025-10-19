/**
 * @name Weak elliptic curve
 * @description Detects cryptographic implementations using elliptic curve algorithms that are 
 *              either unrecognized or known to be weak, which may lead to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string alertMessage, string ellipticCurveIdentifier
where
  // Retrieve the elliptic curve identifier from the cryptographic operation
  ellipticCurveIdentifier = cryptoOperation.getCurveName() and
  (
    // First condition: Algorithm is not recognized
    ellipticCurveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Second condition: Algorithm is recognized but considered weak
    ellipticCurveIdentifier != unknownAlgorithm() and
    not ellipticCurveIdentifier in
      [
        // Approved secure elliptic curves
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
  )
select cryptoOperation, alertMessage