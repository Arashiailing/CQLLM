/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Identifies cryptographic operations utilizing hash algorithms or password hashing algorithms.
 *              This detection focuses on quantum-vulnerable cryptographic primitives within classical
 *              CBOM models, scanning all supported cryptography libraries for relevant operations.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis modules and Semmle cryptography concepts
import python
import semmle.python.Concepts

// Define variables representing cryptographic operations and their algorithms
from Cryptography::CryptographicOperation cryptographicOperation, 
     Cryptography::CryptographicAlgorithm cryptographicAlgorithm
where
  // Establish the relationship between the operation and its algorithm
  cryptographicAlgorithm = cryptographicOperation.getAlgorithm()
  and (
    // Identify operations using hash-based cryptographic algorithms
    cryptographicAlgorithm instanceof Cryptography::HashingAlgorithm
    or cryptographicAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report detected operations with algorithm identification
select cryptographicOperation, 
       "Detected cryptographic hash algorithm: " + cryptographicOperation.getAlgorithm().getName()