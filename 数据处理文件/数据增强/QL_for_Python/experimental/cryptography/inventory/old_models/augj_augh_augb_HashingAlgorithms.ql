/**
 * @name Hash Algorithms Detection
 * @description Identifies all cryptographic operations that utilize hash algorithms,
 *              covering both standard hashing functions and password-specific hashing methods.
 *              The analysis spans across all supported cryptographic libraries in the codebase.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Define variables for cryptographic operations and their associated algorithms
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm cryptoAlgo
where
  // Link the cryptographic operation to its algorithm
  cryptoAlgo = cryptoOp.getAlgorithm() and
  (
    // Identify standard hashing algorithms
    cryptoAlgo instanceof Cryptography::HashingAlgorithm
    or
    // Identify password-specific hashing algorithms
    cryptoAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output the cryptographic operation with algorithm information
select cryptoOp, "Use of algorithm " + cryptoOp.getAlgorithm().getName()