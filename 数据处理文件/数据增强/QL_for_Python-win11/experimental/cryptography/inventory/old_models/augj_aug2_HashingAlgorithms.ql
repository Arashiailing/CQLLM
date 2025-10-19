/**
 * @name Quantum-Vulnerable Cryptographic Hash Detection
 * @description Identifies cryptographic operations using hash algorithms or password hashing algorithms
 *              that are vulnerable to quantum attacks. This query targets quantum-unsafe primitives
 *              in classical Cryptographic Bill of Materials (CBOM) models.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Core Python analysis modules and Semmle cryptography concepts
import python
import semmle.python.Concepts

// Identify cryptographic operations using quantum-vulnerable hash algorithms
from Cryptography::CryptographicOperation cryptoOp, Cryptography::CryptographicAlgorithm algo
where
  // Establish algorithm-operation relationship
  algo = cryptoOp.getAlgorithm()
  and (
    // Detect standard hash algorithms (e.g., SHA-1, SHA-256)
    algo instanceof Cryptography::HashingAlgorithm
    or
    // Detect password hashing algorithms (e.g., PBKDF2, bcrypt)
    algo instanceof Cryptography::PasswordHashingAlgorithm
  )
// Report findings with algorithm identification
select cryptoOp, "Quantum-vulnerable hash algorithm detected: " + cryptoOp.getAlgorithm().getName()