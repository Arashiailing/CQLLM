/**
 * @name All Cryptographic Algorithms
 * @description Identifies cryptographic algorithm implementations across supported libraries,
 *              capturing both algorithm names and block modes used in cryptographic operations.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python and Semmle core libraries
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Extract algorithm name from the cryptographic operation
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode identifier from the cryptographic operation
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName