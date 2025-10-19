/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations that utilize elliptic curve algorithms which are 
 *              either unrecognized or known to be weak, potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveUsage, string securityAlert, string ellipticCurveIdentifier
where
  ellipticCurveIdentifier = ellipticCurveUsage.getCurveName() and
  (
    // Case 1: Unrecognized algorithm
    ellipticCurveIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm
    ellipticCurveIdentifier != unknownAlgorithm() and
    not ellipticCurveIdentifier in 
      ["SECP256R1", "PRIME256V1", // P-256 curve
       "SECP384R1",              // P-384 curve
       "SECP521R1",              // P-521 curve
       "ED25519",                // Ed25519 curve
       "X25519"] and              // X25519 curve
    securityAlert = "Use of weak curve algorithm " + ellipticCurveIdentifier + "."
  )
select ellipticCurveUsage, securityAlert