/**
 * @name Hash Algorithms
 * @description Identifies all potential uses of cryptographic hash algorithms across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle libraries
import python
import semmle.python.Concepts

// Define cryptographic operation and algorithm variables
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm cryptoAlgo
where 
  // Ensure algorithm is associated with the operation
  cryptoAlgo = cryptoOp.getAlgorithm() and
  (
    // Check for standard hashing algorithms
    cryptoAlgo instanceof Cryptography::HashingAlgorithm or
    // Check for password-specific hashing algorithms
    cryptoAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Select operations with algorithm name in result
select cryptoOp, "Use of algorithm " + cryptoOp.getAlgorithm().getName()