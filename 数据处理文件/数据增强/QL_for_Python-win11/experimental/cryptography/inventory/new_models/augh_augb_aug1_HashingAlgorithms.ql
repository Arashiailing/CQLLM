/**
 * @name Cryptographic Hash Algorithm Usage
 * @description Detects all cryptographic hash algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis modules
import python

// Import experimental cryptography detection utilities
import experimental.cryptography.Concepts

// Identify cryptographic hash algorithm instances
from HashAlgorithm cryptoHash

// Generate alert for each detected hash algorithm
select cryptoHash, "Cryptographic hash algorithm detected: " + cryptoHash.getName()