/**
 * @name Vulnerable Elliptic Curve Cryptography
 * @description Detects elliptic curve cryptographic implementations that use
 *              either unrecognized or weak algorithms, which may introduce security risks.
 * @id py/weak-elliptic-curve
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-327
 */

import python
import experimental.cryptography.Concepts

// Define secure curve algorithms that are considered safe
string secureCurveAlgorithm() {
  result in [
    "SECP256R1", "PRIME256V1", // P-256 curve
    "SECP384R1",              // P-384 curve
    "SECP521R1",              // P-521 curve
    "ED25519",                // Ed25519 curve
    "X25519"                  // X25519 curve
  ]
}

from EllipticCurveAlgorithm cryptoImplementation, string securityAlert, string algorithmIdentifier
where
  // Extract the curve identifier from the cryptographic implementation
  algorithmIdentifier = cryptoImplementation.getCurveName() and
  (
    // Scenario 1: Algorithm is not recognized
    algorithmIdentifier = unknownAlgorithm() and
    securityAlert = "Use of unrecognized curve algorithm."
    or
    // Scenario 2: Algorithm is recognized but classified as weak
    algorithmIdentifier != unknownAlgorithm() and
    not algorithmIdentifier = secureCurveAlgorithm() and
    securityAlert = "Use of weak curve algorithm " + algorithmIdentifier + "."
  )
select cryptoImplementation, securityAlert