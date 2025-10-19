/**
 * @name Weak elliptic curve
 * @description Identifies the use of cryptographic elliptic curve algorithms that are either unrecognized or considered weak.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python  // Import Python library for analyzing Python code
import experimental.cryptography.Concepts  // Import experimental cryptography concepts

// Select elliptic curve algorithm operations and define corresponding message and curve name
from EllipticCurveAlgorithm curveOperation, string alertMessage, string curveName
where
  curveName = curveOperation.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    alertMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but weak curve algorithm
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curve
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    alertMessage = "Use of weak curve algorithm " + curveName + "."
  )
select curveOperation, alertMessage  // Output the operation and corresponding message