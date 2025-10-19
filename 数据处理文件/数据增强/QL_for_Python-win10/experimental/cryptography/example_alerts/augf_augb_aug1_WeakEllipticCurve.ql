/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Identifies implementations of elliptic curve cryptographic algorithms that are either
 *              unrecognized or classified as weak, potentially leading to security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm curveImplementation, string alertMessage, string curveName
where
  // Extract curve identifier from the elliptic curve implementation
  curveName = curveImplementation.getCurveName() and
  (
    // Case 1: Unrecognized algorithm detected
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak algorithm detected
    curveName != unknownAlgorithm() and
    not curveName in
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select curveImplementation, alertMessage