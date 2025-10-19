/**
 * @name Weak elliptic curve
 * @description Identifies cryptographic operations using elliptic curve algorithms that are
 *              either unrecognized or considered weak based on security standards.
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
  // Extract the curve identifier once to avoid redundant calls
  curveIdentifier = cryptoOperation.getCurveName() and
  (
    // Case 1: Curve algorithm is not recognized
    curveIdentifier = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Curve algorithm is recognized but not in the approved secure curves list
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select cryptoOperation, alertMessage