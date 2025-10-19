/**
 * @name All Cryptographic Algorithms
 * @description Comprehensive detection of cryptographic algorithm implementations across supported libraries.
 *              This query identifies all cryptographic operations and extracts the algorithm names or block modes used.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import core Python analysis modules and cryptographic concepts from Semmle
import python
import semmle.python.Concepts

// Main query to identify cryptographic operations and extract associated algorithm information
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Condition 1: Extract the algorithm name directly from the cryptographic operation
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Condition 2: Extract the block mode information from the cryptographic operation
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName