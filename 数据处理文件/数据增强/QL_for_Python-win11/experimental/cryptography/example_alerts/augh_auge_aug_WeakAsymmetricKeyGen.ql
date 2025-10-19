/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations
 * that produce keys with inadequate bit length (under 2048 bits),
 * potentially leading to security vulnerabilities.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with insufficient key size
from AsymmetricKeyGen keyGenOperation, DataFlow::Node configNode, int keySizeBits, string algoName
where
  // Retrieve the cryptographic algorithm used in key generation
  algoName = keyGenOperation.getAlgorithm().getName() and
  // Calculate the bit length of the generated key from its configuration
  keySizeBits = keyGenOperation.getKeySizeInBits(configNode) and
  // Verify the key size meets minimum security requirements
  keySizeBits < 2048 and
  // Exclude elliptic curve algorithms due to different security models
  not isEllipticCurveAlgorithm(algoName, _)
// Report findings with security context and configuration details
select keyGenOperation,
  "Insecure asymmetric key size (" + keySizeBits.toString() + " bits) for " +
    algoName + " algorithm configured at $@", configNode, configNode.toString()