/**
 * @name Weak asymmetric cryptographic key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations that use
 * insufficient key lengths (below 2048 bits), rendering them vulnerable
 * to computational brute-force attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric cryptographic key generation operations with inadequate security parameters
from AsymmetricKeyGen keyGenerationInstance, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Extract cryptographic configuration details
  keySizeBits = keyGenerationInstance.getKeySizeInBits(keyConfigNode) and
  algorithmName = keyGenerationInstance.getAlgorithm().getName() and
  // Validate security strength: verify key meets minimum requirements
  keySizeBits < 2048 and
  // Exclude elliptic curve algorithms as they follow different security paradigms
  not isEllipticCurveAlgorithm(algorithmName, _)
// Report vulnerability with contextual information about the weak cryptographic configuration
select keyGenerationInstance,
  "Vulnerable asymmetric key size (" + keySizeBits.toString() + " bits) found for " +
    algorithmName + " algorithm, specified at $@", keyConfigNode, keyConfigNode.toString()