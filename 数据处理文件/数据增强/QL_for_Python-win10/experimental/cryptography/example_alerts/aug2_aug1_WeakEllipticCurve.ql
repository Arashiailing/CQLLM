/**
 * @name Weak elliptic curve
 * @description Identifies the use of cryptographic elliptic curve algorithms that are either unapproved 
 *              or known to be weak, potentially compromising the security of the system.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOperation, string securityWarning, string curveIdentifier
where
  curveIdentifier = ellipticCurveOperation.getCurveName() and
  (
    // Case 1: Unrecognized algorithm
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOperation, securityWarning