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

// Identify cryptographic operations and their associated algorithm identifiers
from Cryptography::CryptographicOperation cryptoOperation, string algorithmName
where 
  // Extract algorithm name from cryptographic operation
  algorithmName = cryptoOperation.getAlgorithm().getName()
  or
  // Extract block mode from cryptographic operation
  algorithmName = cryptoOperation.getBlockMode()
select cryptoOperation, "Use of algorithm " + algorithmName