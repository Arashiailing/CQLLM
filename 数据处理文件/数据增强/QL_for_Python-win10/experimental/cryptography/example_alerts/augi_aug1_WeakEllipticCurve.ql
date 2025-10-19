/**
 * @name Vulnerable Elliptic Curve Implementation
 * @description Detects cryptographic operations that utilize elliptic curve algorithms which are either
 *              not recognized or considered cryptographically weak, potentially leading to security
 *              vulnerabilities in the system.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveOperation, string securityWarning, string curveIdentifier
where
  curveIdentifier = curveOperation.getCurveName() and
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
select curveOperation, securityWarning