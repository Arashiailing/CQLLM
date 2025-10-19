/**
 * @name Hash Algorithms Detection
 * @description Identifies cryptographic hash algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle modules
import python
import semmle.python.Concepts

// Define cryptographic operation and algorithm variables
from Cryptography::CryptographicOperation cryptographicOperation, 
     Cryptography::CryptographicAlgorithm cryptographicAlgorithm
where
  // Establish operation-algorithm relationship
  cryptographicAlgorithm = cryptographicOperation.getAlgorithm()
  and
  // Filter for hash-based algorithm types
  (
    cryptographicAlgorithm instanceof Cryptography::HashingAlgorithm or
    cryptographicAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output operation with algorithm identification message
select cryptographicOperation, 
       "Algorithm in use: " + cryptographicOperation.getAlgorithm().getName()