/**
 * @name Hash Algorithms
 * @description Identifies cryptographic hash algorithm usage across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python core and Semmle cryptographic concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations using hash algorithms
from Cryptography::CryptographicOperation cryptoOperation, Cryptography::CryptographicAlgorithm cryptoAlgorithm
where
  // Associate operation with its algorithm
  cryptoAlgorithm = cryptoOperation.getAlgorithm() and
  // Filter for hash-based algorithms (both standard and password hashing)
  (
    cryptoAlgorithm instanceof Cryptography::HashingAlgorithm or
    cryptoAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report operation with algorithm name
select cryptoOperation, "Use of algorithm " + cryptoOperation.getAlgorithm().getName()