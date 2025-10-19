/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Identifies all cryptographic operations utilizing hash algorithms or password hashing algorithms
 *              across supported cryptography libraries. This detection targets quantum-vulnerable
 *              cryptographic primitives in classical CBOM models.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis modules and Semmle cryptography concepts
import python
import semmle.python.Concepts

// Define source variables with semantic clarity
from Cryptography::CryptographicOperation cryptoOperation, Cryptography::CryptographicAlgorithm cryptoAlgorithm
where
  // Establish algorithm-operation relationship
  cryptoAlgorithm = cryptoOperation.getAlgorithm()
  and (
    // Identify hash-based cryptographic algorithms
    cryptoAlgorithm instanceof Cryptography::HashingAlgorithm
    or cryptoAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report operations with algorithm identification
select cryptoOperation, "Detected cryptographic hash algorithm: " + cryptoOperation.getAlgorithm().getName()