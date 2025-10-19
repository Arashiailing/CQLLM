/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Detects asymmetric cryptographic key generation operations that employ
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

// Identify asymmetric cryptographic key generation instances with inadequate security parameters
from AsymmetricKeyGen keyGenerationInstance, DataFlow::Node keyConfigNode, int keySizeBits, string algorithmName
where
  // Extract cryptographic configuration details
  keySizeBits = keyGenerationInstance.getKeySizeInBits(keyConfigNode) and
  algorithmName = keyGenerationInstance.getAlgorithm().getName() and
  // Apply security criteria: verify key meets minimum strength requirements
  (
    keySizeBits < 2048 and
    // Omit elliptic curve cryptography from this validation since they utilize distinct security parameters
    not isEllipticCurveAlgorithm(algorithmName, _)
  )
// Construct security alert with comprehensive context about the vulnerable cryptographic configuration
select keyGenerationInstance,
  "Inadequate asymmetric key length (" + keySizeBits.toString() + " bits) identified for " +
    algorithmName + " algorithm, specified at $@", keyConfigNode, keyConfigNode.toString()