/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Identifies implementations of cryptographic hash algorithms across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle modules
import python
import semmle.python.Concepts

// Select cryptographic operations and their associated algorithms
from Cryptography::CryptographicOperation cryptographicOperation, 
     Cryptography::CryptographicAlgorithm cryptographicAlgorithm
where 
  // Establish relationship between operation and algorithm
  cryptographicAlgorithm = cryptographicOperation.getAlgorithm()
  and (
    // Filter for hash-related algorithm types
    cryptographicAlgorithm instanceof Cryptography::HashingAlgorithm
    or
    cryptographicAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output operation with algorithm identification message
select cryptographicOperation, 
       "Algorithm in use: " + cryptographicOperation.getAlgorithm().getName()