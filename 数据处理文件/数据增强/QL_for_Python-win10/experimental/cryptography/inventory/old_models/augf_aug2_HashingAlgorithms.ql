/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Identifies cryptographic operations using hash algorithms or password hashing algorithms
 *              across supported cryptography libraries. Targets quantum-vulnerable primitives
 *              in classical CBOM models.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

// Define source variables with enhanced semantics
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm cryptoAlgo
where
  // Establish algorithm-operation relationship
  cryptoAlgo = cryptoOp.getAlgorithm()
  and (
    // Identify hash-based cryptographic algorithms
    cryptoAlgo instanceof Cryptography::HashingAlgorithm
    or cryptoAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report operations with algorithm identification
select cryptoOp, "Detected cryptographic hash algorithm: " + cryptoOp.getAlgorithm().getName()