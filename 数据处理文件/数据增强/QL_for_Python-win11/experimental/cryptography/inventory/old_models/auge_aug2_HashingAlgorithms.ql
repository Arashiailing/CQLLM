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
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm hashAlgo
where
  // Establish the relationship between the operation and its algorithm
  hashAlgo = cryptoOp.getAlgorithm()
  and (
    // Identify operations using hash-based cryptographic algorithms
    hashAlgo instanceof Cryptography::HashingAlgorithm
    or hashAlgo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report detected operations with algorithm identification
select cryptoOp, "Detected cryptographic hash algorithm: " + cryptoOp.getAlgorithm().getName()