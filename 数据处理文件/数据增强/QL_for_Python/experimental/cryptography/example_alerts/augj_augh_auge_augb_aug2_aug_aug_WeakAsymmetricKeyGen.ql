/**
 * @name Weak asymmetric cryptographic key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations that use
 * insufficient key lengths (below 2048 bits), making them vulnerable
 * to computational brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Find asymmetric cryptographic key generation operations with inadequate security parameters
from AsymmetricKeyGen cryptoKeyGen, DataFlow::Node keySizeConfigNode, int keyBitLength, string cryptoAlgorithm
where
  // Extract cryptographic configuration details
  cryptoAlgorithm = cryptoKeyGen.getAlgorithm().getName() and
  keyBitLength = cryptoKeyGen.getKeySizeInBits(keySizeConfigNode) and
  // Validate security requirements: check if key length meets minimum standards
  keyBitLength < 2048 and
  // Exclude elliptic curve cryptography from this check due to different security parameters
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
// Create security alert with contextual information about the vulnerable cryptographic configuration
select cryptoKeyGen,
  "Insecure asymmetric key length (" + keyBitLength.toString() + " bits) found for " +
    cryptoAlgorithm + " algorithm, specified at $@", keySizeConfigNode, keySizeConfigNode.toString()