/**
 * @name Weak key generation key size (< 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * using insufficiently large keys (less than 2048 bits).
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric key generation operations with weak key sizes
from AsymmetricKeyGen asymmetricKeyGenerationOperation, 
     DataFlow::Node configurationSource, 
     int keyBitLength, 
     string algorithmName
where
  // Retrieve algorithm identification
  algorithmName = asymmetricKeyGenerationOperation.getAlgorithm().getName() and
  // Exclude elliptic curve algorithms (use different security models)
  not isEllipticCurveAlgorithm(algorithmName, _) and
  // Extract key size from configuration source
  keyBitLength = asymmetricKeyGenerationOperation.getKeySizeInBits(configurationSource) and
  // Validate key strength against security threshold
  keyBitLength < 2048
// Report findings with contextual information
select asymmetricKeyGenerationOperation,
  "Weak asymmetric key size (" + keyBitLength.toString() + " bits) for algorithm " +
    algorithmName + " configured at $@", configurationSource, configurationSource.toString()