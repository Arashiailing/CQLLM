/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation processes that utilize
 * inadequate key lengths (under 2048 bits), making them susceptible to
 * computational brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Locate asymmetric cryptographic key generation instances with insufficient security parameters
from AsymmetricKeyGen cryptoKeyGeneration, DataFlow::Node configurationNode, int keyBitLength, string cryptoAlgorithm
where
  // Retrieve cryptographic configuration parameters
  keyBitLength = cryptoKeyGeneration.getKeySizeInBits(configurationNode) and
  cryptoAlgorithm = cryptoKeyGeneration.getAlgorithm().getName() and
  // Security validation: ensure key meets minimum strength requirements
  (
    keyBitLength < 2048 and
    // Exclude elliptic curve cryptography from this check as they use different security parameters
    not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
  )
// Generate alert with detailed context about the vulnerable cryptographic configuration
select cryptoKeyGeneration,
  "Insufficient asymmetric key length (" + keyBitLength.toString() + " bits) detected for " +
    cryptoAlgorithm + " algorithm, configured at $@", configurationNode, configurationNode.toString()