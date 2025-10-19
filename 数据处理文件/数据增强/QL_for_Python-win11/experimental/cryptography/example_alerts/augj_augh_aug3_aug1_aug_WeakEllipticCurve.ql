/**
 * @name Weak elliptic curve detection
 * @description Detects cryptographic operations employing elliptic curve algorithms that are
 *              either unidentified or categorized as weak based on recognized security benchmarks.
 *              This analysis assists in identifying possible security weaknesses in cryptographic implementations.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveCryptoOperation, string vulnerabilityMessage, string curveName
where
  // Retrieve the curve name from the cryptographic operation
  curveName = curveCryptoOperation.getCurveName() and
  
  // Check if the curve is either unrecognized or weak
  (
    // Condition 1: The curve algorithm is not recognized by the system
    // This indicates potential use of custom or non-standard curves
    curveName = unknownAlgorithm() and
    vulnerabilityMessage = "Use of unrecognized curve algorithm."
    or
    // Condition 2: The curve algorithm is recognized but not in the approved secure list
    // These curves are known to have security weaknesses or are deprecated
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    vulnerabilityMessage = "Use of weak curve algorithm " + curveName + "."
  )
select curveCryptoOperation, vulnerabilityMessage