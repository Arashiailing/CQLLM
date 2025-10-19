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

// Select cryptographic operations and their associated algorithms
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm cryptoAlgo
where
  // Establish relationship between operation and algorithm
  cryptoAlgo = cryptoOp.getAlgorithm() and
  // Filter for hash-related algorithm types
  (
    cryptoAlgo instanceof Cryptography::HashingAlgorithm or
    cryptoAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output operation with algorithm identification message
select cryptoOp, "Algorithm in use: " + cryptoOp.getAlgorithm().getName()