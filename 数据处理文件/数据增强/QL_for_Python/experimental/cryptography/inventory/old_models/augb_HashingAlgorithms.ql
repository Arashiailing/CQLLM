/**
 * @name Hash Algorithms
 * @description Identifies all instances where cryptographic hash algorithms are utilized within the codebase,
 *              including both standard hashing algorithms and password-specific hashing algorithms.
 *              This detection is performed across all supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import necessary Python and Semmle libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Define variables for cryptographic operations and algorithms
from Cryptography::CryptographicOperation cryptoOperation, Cryptography::CryptographicAlgorithm cryptoAlgorithm
where
  // Establish relationship between operation and its algorithm
  cryptoAlgorithm = cryptoOperation.getAlgorithm() and
  (
    // Check if the algorithm is a standard hashing algorithm
    cryptoAlgorithm instanceof Cryptography::HashingAlgorithm or
    // Check if the algorithm is a password-specific hashing algorithm
    cryptoAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Select the cryptographic operation and provide a descriptive message about the algorithm used
select cryptoOperation, "Use of algorithm " + cryptoOperation.getAlgorithm().getName()