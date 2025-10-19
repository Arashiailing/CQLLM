/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries,
 *              including both core algorithms and block modes.
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
from Cryptography::CryptographicOperation cryptographicOp, string algoIdentifier
where 
  // Extract primary algorithm name from cryptographic operation
  algoIdentifier = cryptographicOp.getAlgorithm().getName()
  or
  // Extract block mode identifier from cryptographic operation
  algoIdentifier = cryptographicOp.getBlockMode()
select cryptographicOp, "Use of algorithm " + algoIdentifier