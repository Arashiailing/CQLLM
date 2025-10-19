/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations and block modes across supported libraries.
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
from Cryptography::CryptographicOperation cryptoOperation, string algoName
where 
  // Extract algorithm name from cryptographic operation
  algoName = cryptoOperation.getAlgorithm().getName()
  or
  // Extract block mode from cryptographic operation
  algoName = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algoName