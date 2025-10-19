/**
 * @name Hash Algorithms
 * @description Detects usage of cryptographic hash functions across supported libraries
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python core and Semmle cryptographic concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations utilizing hash algorithms
from Cryptography::CryptographicOperation hashOperation, Cryptography::CryptographicAlgorithm hashAlgorithm
where
  // Establish relationship between operation and its algorithm
  hashAlgorithm = hashOperation.getAlgorithm() and
  // Filter for hash-based algorithms (standard hashing and password hashing)
  (
    hashAlgorithm instanceof Cryptography::HashingAlgorithm or
    hashAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report operation with algorithm identification
select hashOperation, "Use of algorithm " + hashOperation.getAlgorithm().getName()