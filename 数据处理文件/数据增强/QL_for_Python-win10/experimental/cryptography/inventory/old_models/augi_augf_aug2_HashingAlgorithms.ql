/**
 * @name Quantum-Vulnerable Cryptographic Hash Detection
 * @description Identifies cryptographic operations utilizing hash algorithms or password hashing algorithms
 *              across various cryptography libraries. This query targets quantum-vulnerable primitives
 *              within classical CBOM (Cryptographic Bill of Materials) models, providing visibility
 *              into potentially insecure cryptographic practices.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Define source variables with enhanced semantics
from Cryptography::CryptographicOperation cryptographicOperation, 
     Cryptography::CryptographicAlgorithm algorithmInstance
where
  // Establish relationship between cryptographic operation and its algorithm
  algorithmInstance = cryptographicOperation.getAlgorithm()
  and (
    // Identify hash-based cryptographic algorithms (vulnerable to quantum computing)
    algorithmInstance instanceof Cryptography::HashingAlgorithm
    or algorithmInstance instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report operations with algorithm identification for security assessment
select cryptographicOperation, 
       "Detected quantum-vulnerable cryptographic hash algorithm: " + 
       cryptographicOperation.getAlgorithm().getName()