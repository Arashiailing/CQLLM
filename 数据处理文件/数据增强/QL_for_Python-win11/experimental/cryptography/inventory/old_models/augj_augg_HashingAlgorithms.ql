/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Detects all instances where cryptographic hash functions are utilized within the codebase,
 *              including both standard hashing and password-specific hashing algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle libraries
import python
import semmle.python.Concepts

// Identify cryptographic operations that utilize hash algorithms
from Cryptography::CryptographicOperation cryptographicOperation
where 
  exists(Cryptography::CryptographicAlgorithm cryptographicAlgorithm |
    cryptographicAlgorithm = cryptographicOperation.getAlgorithm() and
    (
      // Check for standard hashing algorithms
      cryptographicAlgorithm instanceof Cryptography::HashingAlgorithm or
      // Check for password-specific hashing algorithms
      cryptographicAlgorithm instanceof Cryptography::PasswordHashingAlgorithm
    )
  )
// Select operations with algorithm name in result
select cryptographicOperation, "Use of algorithm " + cryptographicOperation.getAlgorithm().getName()