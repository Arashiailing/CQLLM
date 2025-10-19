/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import essential Python and Semmle core libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Retrieve primary algorithm name from cryptographic operation
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode identifier when applicable
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName