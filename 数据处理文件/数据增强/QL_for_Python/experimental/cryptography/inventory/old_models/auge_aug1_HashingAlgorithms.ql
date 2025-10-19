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
from Cryptography::CryptographicOperation cryptOp, Cryptography::CryptographicAlgorithm cryptAlgo
where
  // Establish relationship between operation and algorithm
  cryptAlgo = cryptOp.getAlgorithm()
  // Filter for hash-related algorithm types
  and (
    cryptAlgo instanceof Cryptography::HashingAlgorithm
    or cryptAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Output operation with algorithm identification message
select cryptOp, "Algorithm in use: " + cryptOp.getAlgorithm().getName()