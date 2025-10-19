/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * This query identifies cryptographic implementations that generate asymmetric keys
 * with insufficient bit length, potentially vulnerable to brute-force attacks.
 * The security threshold for most asymmetric algorithms is 2048 bits; keys below
 * this size are considered cryptographically weak.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with insufficient key strength
from AsymmetricKeyGen keyGenOperation, DataFlow::Node keySizeConfigNode, int keyBitLength, string cryptoAlgorithm
where
  // Extract cryptographic algorithm and key size information
  cryptoAlgorithm = keyGenOperation.getAlgorithm().getName() and
  keyBitLength = keyGenOperation.getKeySizeInBits(keySizeConfigNode) and
  // Verify key strength against minimum security requirements
  keyBitLength < 2048 and
  // Exclude elliptic curve cryptography (ECC) algorithms as they follow
  // different security models and key size equivalencies
  not isEllipticCurveAlgorithm(cryptoAlgorithm, _)
// Report findings with detailed context about the weak key configuration
select keyGenOperation,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    cryptoAlgorithm + " configured at $@", keySizeConfigNode, keySizeConfigNode.toString()