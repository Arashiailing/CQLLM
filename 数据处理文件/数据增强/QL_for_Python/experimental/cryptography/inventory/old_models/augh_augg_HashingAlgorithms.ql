/**
 * @name Hash Algorithms Detection
 * @description Identifies potential uses of cryptographic hash algorithms across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python and Semmle libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Define variables for cryptographic operation and algorithm identification
from Cryptography::CryptographicOperation cryptoOperation, Cryptography::CryptographicAlgorithm cryptoAlgorithm
where 
  // Establish relationship between operation and its algorithm
  cryptoAlgorithm = cryptoOperation.getAlgorithm()
  and
  (
    // Identify standard cryptographic hashing algorithms
    cryptoAlgorithm instanceof Cryptography::HashingAlgorithm
    or
    // Identify password-specific hashing algorithms
    cryptoAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output cryptographic operations with algorithm name in result message
select cryptoOperation, "Use of algorithm " + cryptoOperation.getAlgorithm().getName()