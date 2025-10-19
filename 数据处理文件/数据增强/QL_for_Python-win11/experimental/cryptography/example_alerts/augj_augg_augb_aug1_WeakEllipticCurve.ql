/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Detects elliptic curve cryptographic implementations that utilize
 *              either unrecognized or weak algorithms, which may introduce security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImpl, string warningMsg, string curveIdentifier
where
  // Extract the curve identifier from the elliptic curve implementation
  curveIdentifier = curveImpl.getCurveName() and
  (
    // Check for unrecognized algorithm
    curveIdentifier = unknownAlgorithm() and
    warningMsg = "Use of unrecognized curve algorithm."
    or
    // Check for weak algorithm (recognized but not in the secure set)
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMsg = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select curveImpl, warningMsg