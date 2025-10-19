/**
 * @name Weak elliptic curve
 * @description Detects cryptographic operations utilizing elliptic curve algorithms that are either
 *              unrecognized or deemed weak based on established security standards.
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
  // Extract the curve identifier from the elliptic curve cryptographic operation
  curveIdentifier = ellipticCurveOperation.getCurveName()
  and
  (
    // Case 1: The curve algorithm is not recognized by the system
    curveIdentifier = unknownAlgorithm()
    and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but not in the approved secure list
    curveIdentifier != unknownAlgorithm()
    and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ]
    and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOperation, securityWarning