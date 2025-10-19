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

// Identify asymmetric cryptographic key generation with insufficient security strength
from AsymmetricKeyGen keyGenInstance, DataFlow::Node configLocation, int keySizeBits, string algorithmName
where
  // Extract cryptographic configuration parameters
  keySizeBits = keyGenInstance.getKeySizeInBits(configLocation) and
  algorithmName = keyGenInstance.getAlgorithm().getName() and
  // Apply security validation: check key length and exclude ECC algorithms
  keySizeBits < 2048 and
  not isEllipticCurveAlgorithm(algorithmName, _)
// Generate security alert with cryptographic context details
select keyGenInstance,
  "Insufficient asymmetric key length (" + keySizeBits.toString() + " bits) detected for " +
    algorithmName + " algorithm, configured at $@", configLocation, configLocation.toString()