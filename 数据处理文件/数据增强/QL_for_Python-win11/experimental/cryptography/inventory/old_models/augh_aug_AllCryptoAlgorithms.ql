/**
 * @name All Cryptographic Algorithms
 * @description Detects all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import Python and Semmle core libraries
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algoName
where 
  // Case 1: Extract algorithm name directly from operation
  algoName = cryptoOp.getAlgorithm().getName()
  or
  // Case 2: Extract block mode identifier from operation
  algoName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoName