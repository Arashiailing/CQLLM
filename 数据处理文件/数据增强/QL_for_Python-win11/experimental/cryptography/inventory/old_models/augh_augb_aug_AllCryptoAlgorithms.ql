/**
 * @name All Cryptographic Algorithms
 * @description Identifies all cryptographic algorithm implementations across supported libraries.
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
from Cryptography::CryptographicOperation cryptoOp, string algorithmName
where 
  // Extract algorithm name from cryptographic operation
  algorithmName = cryptoOp.getAlgorithm().getName()
  or
  // Extract block mode from cryptographic operation
  algorithmName = cryptoOp.getBlockMode()
select cryptoOp, "Use of algorithm " + algorithmName