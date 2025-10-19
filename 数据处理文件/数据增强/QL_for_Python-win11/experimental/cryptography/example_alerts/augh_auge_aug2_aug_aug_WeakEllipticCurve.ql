/**
 * @name Weak Elliptic Curve Cryptography Usage
 * @description Identifies cryptographic operations using elliptic curve algorithms that are either
 *              unrecognized or considered cryptographically insecure, potentially introducing security vulnerabilities.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

from EllipticCurveAlgorithm cryptoOperation, string warningMessage, string curveName
where
  // Extract the elliptic curve identifier from the cryptographic operation
  curveName = cryptoOperation.getCurveName() and
  (
    // Case 1: Unrecognized curve algorithm
    curveName = unknownAlgorithm() and
    warningMessage = "Use of unrecognized curve algorithm."
    or
    // Case 2: Recognized but cryptographically weak curve
    curveName != unknownAlgorithm() and
    not curveName =
      [
        "SECP256R1", "PRIME256V1", // P-256 curves
        "SECP384R1",              // P-384 curve
        "SECP521R1",              // P-521 curve
        "ED25519",                // Ed25519 curve
        "X25519"                  // X25519 curve
      ] and
    warningMessage = "Use of weak curve algorithm " + curveName + "."
  )
select cryptoOperation, warningMessage