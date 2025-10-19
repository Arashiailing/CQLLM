/**
 * @name Weak elliptic curve detection
 * @description Identifies cryptographic implementations utilizing elliptic curve algorithms that are
 *              either unrecognized or classified as weak according to established security standards.
 *              This query helps detect potential security vulnerabilities in cryptographic code.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm ellipticCurveOp, string securityWarning, string curveIdentifier
where
  // Extract the curve identifier from the cryptographic operation
  curveIdentifier = ellipticCurveOp.getCurveName() and
  (
    // Case 1: The curve algorithm is unrecognized by the system
    // This indicates potential use of custom or non-standard curves
    curveIdentifier = unknownAlgorithm() and
    securityWarning = "Use of unrecognized curve algorithm."
    or
    // Case 2: The curve algorithm is recognized but not in the approved secure list
    // These curves are known to have security weaknesses or are deprecated
    curveIdentifier != unknownAlgorithm() and
    not curveIdentifier in
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    securityWarning = "Use of weak curve algorithm " + curveIdentifier + "."
  )
select ellipticCurveOp, securityWarning