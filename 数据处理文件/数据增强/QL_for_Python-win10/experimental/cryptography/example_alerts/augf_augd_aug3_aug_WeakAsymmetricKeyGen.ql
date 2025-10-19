/**
 * @name Weak asymmetric key generation (key size < 2048 bits)
 * @description
 * Identifies asymmetric cryptographic key generation operations
 * that utilize keys with insufficient length (below 2048 bits),
 * which may be vulnerable to cryptographic attacks.
 * @id py/weak-asymmetric-key-gen-size
 * @kind problem
 * @problem.severity error
 * @precision high
 * @tags external/cwe/cwe-326
 */

import python
import experimental.cryptography.Concepts

// Find asymmetric key generation operations with weak key sizes
from AsymmetricKeyGen keyGeneration, 
     DataFlow::Node keyConfigSource, 
     int keyBitLength, 
     string algorithmName
where
  // Extract the algorithm name and filter out elliptic curve algorithms
  algorithmName = keyGeneration.getAlgorithm().getName() and
  not isEllipticCurveAlgorithm(algorithmName, _) and
  
  // Determine the key size in bits from the configuration source
  keyBitLength = keyGeneration.getKeySizeInBits(keyConfigSource) and
  
  // Check if the key size is below the recommended security threshold
  keyBitLength < 2048
// Generate alert with details about the weak key generation
select keyGeneration,
  "Vulnerable asymmetric key size (" + keyBitLength.toString() + " bits) detected for " +
    algorithmName + " algorithm, configured at $@", keyConfigSource, keyConfigSource.toString()