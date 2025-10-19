/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations utilizing elliptic curves that are either 
 *              unrecognized or documented as weak, potentially introducing security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOperation, string securityAlert, string ellipticCurveIdentifier
where
  // Retrieve the elliptic curve identifier from the cryptographic operation
  ellipticCurveIdentifier = ellipticCurveOperation.getCurveName() and
  (
    // Case 1: Check for unrecognized/unknown curve algorithms
    ellipticCurveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Check for recognized but cryptographically weak curve algorithms
    ellipticCurveIdentifier != unknownAlgorithm() and
    not ellipticCurveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityAlert = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
  )
select ellipticCurveOperation, securityAlert