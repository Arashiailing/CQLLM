/**
 * @name Quantum-Vulnerable Cryptographic Hash Detection
 * @description Identifies cryptographic operations utilizing hash-based or password-hashing algorithms.
 *              This detection targets quantum-vulnerable primitives within classical CBOM models,
 *              scanning all supported cryptography libraries for relevant cryptographic operations.
 * @kind problem
 * @id py/quantum-readiness/cbom/classical-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       quantum-vulnerability
 */

// Import core Python analysis modules and Semmle cryptography concepts
import python
import semmle.python.Concepts

// Define cryptographic operation and algorithm variables
from Cryptography::CryptographicOperation cryptographicOperation, 
     Cryptography::CryptographicAlgorithm cryptoAlgorithm
where
  // Establish relationship between operation and its algorithm
  cryptoAlgorithm = cryptographicOperation.getAlgorithm()
  and (
    // Identify hash-based cryptographic algorithms
    cryptoAlgorithm instanceof Cryptography::HashingAlgorithm
    // Include password-hashing algorithms
    or cryptoAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report detected operations with algorithm identification
select cryptographicOperation, 
       "Detected quantum-vulnerable cryptographic hash: " + 
       cryptographicOperation.getAlgorithm().getName()