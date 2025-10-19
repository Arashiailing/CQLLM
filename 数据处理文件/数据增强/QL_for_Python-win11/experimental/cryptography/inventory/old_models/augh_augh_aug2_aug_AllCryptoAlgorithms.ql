/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

// Import required Python and Semmle core libraries for cryptographic analysis
import python
import semmle.python.Concepts

// Identify cryptographic operations and extract their algorithm identifiers
from Cryptography::CryptographicOperation cryptoOp, string algoIdentifier
where 
  // Extract algorithm name from the cryptographic operation
  algoIdentifier = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode identifier when applicable
  algoIdentifier = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algoIdentifier